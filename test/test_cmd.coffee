assert = require 'assert'
fs = require 'fs'
execSync = require('child_process').execSync
spawnSync = require('child_process').spawnSync

suite 'Cmd output', ->
  setup ->
    process.chdir __dirname
    @cmd = '../bin/coffee-inline-map'

  test 'empty stdin', ->
    r = (execSync "echo '' | #{@cmd}").toString()
    assert.equal '', r

  test 'js with source map from usual coffee from stdin', ->
    r = (execSync "#{@cmd} < data/src/a.coffee").toString()
    assert.equal (fs.readFileSync 'data/src/a.js.stdin.should').toString(), r

  test 'js with source map from usual coffee', ->
    r = (execSync "#{@cmd} data/src/a.coffee").toString()
    assert.equal (fs.readFileSync 'data/src/a.js.should').toString(), r

  test 'js without source map from usual coffee', ->
    r = (execSync "#{@cmd} --no-map data/src/a.coffee").toString()
    assert.equal (fs.readFileSync 'data/src/a.js.mapless.should').toString(), r

  test 'js with source map from litcoffee', ->
    r = (execSync "#{@cmd} data/src/b.litcoffee").toString()
    assert.equal (fs.readFileSync 'data/src/b.js.should').toString(), r

  test 'error due to not recognizing litcoffee', ->
    r = spawnSync @cmd, { input: fs.readFileSync "data/src/b.coffee.md" }
    assert.equal 1, r.status
    assert.equal "[stdin]:3:1: error: unexpected indentation\n    module.exports = 'hi'\n\^^^^\n", r.stderr.toString()

  test 'js with source map from litcoffee from stdin', ->
    r = (execSync "#{@cmd} -l < data/src/b.coffee.md").toString()
    assert.equal (fs.readFileSync 'data/src/b.js.stdin.should').toString(), r

  test 'bare js with source map usual coffee', ->
    r = (execSync "#{@cmd} -b data/src/a.coffee").toString()
    assert.equal (fs.readFileSync 'data/src/a.js.bare.should').toString(), r
