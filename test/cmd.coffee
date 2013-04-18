assert = require 'assert'
fs = require 'fs'
execSync = require 'execSync'

suite 'Cmd output', ->
  setup ->
    process.chdir __dirname
    @cmd = '../bin/coffee-inline-map'

  test 'js with source map from usual coffee', ->
    r = execSync.exec "#{@cmd} data/src/a.coffee"
    assert.equal (fs.readFileSync 'data/src/a.js.should').toString(), r.stdout

  test 'js without source map from usual coffee', ->
    r = execSync.exec "#{@cmd} --no-map data/src/a.coffee"
    assert.equal (fs.readFileSync 'data/src/a.js.mapless.should').toString(), r.stdout

  test 'js with source map from litcoffee', ->
    r = execSync.exec "#{@cmd} data/src/b.litcoffee"
    assert.equal (fs.readFileSync 'data/src/b.js.should').toString(), r.stdout
