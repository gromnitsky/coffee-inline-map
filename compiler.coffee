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
  progver: JSON.parse(fs.readFileSync "#{__dirname}/../package.json").version

  maps: true
  output: process.stdout

errx = (exit_code, msg) ->
  console.error "#{conf.progname} error: #{msg}" unless conf.quiet
  process.exit exit_code if exit_code

parse_opts = (src) ->
  opt = [
    ["-h", "--help", "output usage information & exit"]
    ["-V", "--version", "output the version number & exit"]
    ["-o", "--output [FILE]", "write result to a FILE instead of stdout"]
    ["--no-maps", "don't include inline source maps (why?)"]
  ]
  p = new optparse.OptionParser opt
  p.banner = "Usage: #{conf.progname} [options] file.coffee"

  p.on 'no-maps', -> conf.maps = false

  p.on 'help', ->
    console.log p.toString()
    process.exit 0

  p.on 'version', ->
    console.log conf.progver
    process.exit 0

  p.on 'output', (unused, val) -> conf.output = val

  p.on (o) -> errx 1, "unknown option #{o}"

  [(p.parse src), p]

is_literate = (fname) ->
  return true if '.litcoffee' == path.extname fname
  false

# Crash or return a string.
compile = (file) ->
  try
    src = (fs.readFileSync file).toString()
  catch e
    errx 1, "#{file} reading: #{e.message}"

  try
    compiled = coffee.compile src, {
      sourceMap: conf.maps
      generatedFile: file
      inline: true
      literate: is_literate(file)
    }
  catch e
    inColor = if process.stderr.isTTY then true else false
    console.error (coffee_helpers.prettyErrorMessage e, file, src, inColor)
    process.exit 1

  if conf.maps
    comment = convert
      .fromJSON(compiled.v3SourceMap)
      .setProperty('sources', [file])
      .toComment()

    "#{compiled.js}\n#{comment}"
  else
    compiled.toString()


exports.main = ->
  [args, p] = parse_opts process.argv
  args = args[2..-1]
  if args.length != 1
    console.log p.toString()
    process.exit 1

  js = compile args[0]

  # create output stream only after a successful compilation
  unless conf.output instanceof Stream
    conf.output = fs.createWriteStream conf.output
    conf.output.on 'error', (err) ->
      errx 1, "output stream: #{err.message}"

  conf.output.write js
  conf.output.end() unless conf.output.isTTY
