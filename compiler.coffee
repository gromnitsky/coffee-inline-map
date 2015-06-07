fs = require 'fs'
path = require 'path'
Stream = require 'stream'

coffee = require 'coffee-script'
coffee_helpers = require 'coffee-script/lib/coffee-script/helpers'
convert = require 'convert-source-map'
optparse = require 'optparse'

conf =
  quiet: false
  progname: path.basename process.argv[1]

  maps: true
  output: process.stdout
  stdin_literate: false
  bare: false
  header: true

errx = (exit_code, msg) ->
  console.error "#{conf.progname} error: #{msg}" unless conf.quiet
  process.exit exit_code if exit_code

user_agent = ->
  ver = JSON.parse(fs.readFileSync "#{__dirname}/../package.json").version
  ver_cs = require('coffee-script/lib/coffee-script/coffee-script').VERSION
  "#{conf.progname}/#{ver} (CoffeeScript #{ver_cs}; #{process.platform}; #{process.arch}) node/#{process.versions.node}"

parse_opts = (src) ->
  opt = [
    ["-h", "--help", "output usage information & exit"]
    ["-V", "--version", "output the version number & exit"]
    ["-o", "--output [FILE]", "write result to a FILE instead of stdout"]
    ["-l", "--literate", "treat stdin as literate style coffee-script"]
    ["-b", "--bare", "compile without a top-level function wrapper"]
    ["--no-map", "don't include inline source map (why?)"]
  ]
  p = new optparse.OptionParser opt
  p.banner = "Usage: #{conf.progname} [options] [file.coffee]"

  p.on 'no-map', -> conf.maps = false

  p.on 'bare', -> conf.bare = true

  p.on 'help', ->
    console.log p.toString()
    process.exit 0

  p.on 'version', ->
    console.log user_agent()
    process.exit 0

  p.on 'output', (unused, val) -> conf.output = val

  p.on 'literate', -> conf.stdin_literate = true

  p.on (o) -> errx 1, "unknown option #{o}"

  [(p.parse src), p]

read_file = (fname) ->
  try
    fs.readFileSync(fname).toString()
  catch e
    errx 1, "#{fname} reading: #{e.message}"

# TODO: fix this for Windows
read_stdin = ->
  read_file '/dev/stdin'

# Crash or return a string.
compile = (fname, fcontent, opt = {}) ->
  return '' if fcontent.match /^\s*$/

  options = {
    sourceMap: conf.maps
    generatedFile: fname
    filename: fname
    bare: conf.bare
    header: conf.header
    inline: true
    literate: coffee_helpers.isLiterate(fname)
  }
  # override computed options from user provided opt object
  options[key] = val for key,val of opt

  try
    compiled = coffee.compile fcontent, options
  catch e
    console.error coffee_helpers.updateSyntaxError e.toString(), fcontent, fname
    process.exit 1

  if conf.maps
    comment = convert
      .fromJSON(compiled.v3SourceMap)
      .setProperty('sources', [fname])
      .toComment()

    "#{compiled.js}\n#{comment}"
  else
    compiled.toString()


exports.main = ->
  [args, p] = parse_opts process.argv
  args = args[2..-1]

  if args.length
    js = compile args[0], read_file args[0]
  else
    js = compile '[stdin]', read_stdin(), { literate: conf.stdin_literate }

  # create output stream only after a successful compilation
  unless conf.output instanceof Stream
    conf.output = fs.createWriteStream conf.output

  conf.output.on 'error', (err) ->
    errx 1, "output stream: #{err.message}"

  conf.output.write js
  conf.output.end() if conf.output.path
