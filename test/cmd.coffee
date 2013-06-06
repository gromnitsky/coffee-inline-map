assert = require 'assert'
fs = require 'fs'
execSync = require 'execSync'

suite 'Cmd output', ->
  setup ->
    process.chdir __dirname
    @cmd = '../bin/coffee-inline-map'

  test 'empty stdin', ->
    r = execSync.exec "echo '' | #{@cmd}"
    assert.equal '', r.stdout

  test 'js with source map from usual coffee from stdin', ->
    r = execSync.exec "#{@cmd} < data/src/a.coffee"
    assert.equal (fs.readFileSync 'data/src/a.js.stdin.should').toString(), r.stdout

  test 'js with source map from usual coffee', ->
    r = execSync.exec "#{@cmd} data/src/a.coffee"
    assert.equal (fs.readFileSync 'data/src/a.js.should').toString(), r.stdout

  test 'js without source map from usual coffee', ->
    r = execSync.exec "#{@cmd} --no-map data/src/a.coffee"
    assert.equal (fs.readFileSync 'data/src/a.js.mapless.should').toString(), r.stdout

  test 'js with source map from litcoffee', ->
    r = execSync.exec "#{@cmd} data/src/b.litcoffee"
    assert.equal (fs.readFileSync 'data/src/b.js.should').toString(), r.stdout

  test 'error due to not recognizing litcoffee', ->
    r = execSync.exec "#{@cmd} < data/src/b.coffee.md"
    assert.equal 1, r.code

  test 'js with source map from litcoffee from stdin', ->
    r = execSync.exec "#{@cmd} -l < data/src/b.coffee.md"
    assert.equal (fs.readFileSync 'data/src/b.js.stdin.should').toString(), r.stdout
