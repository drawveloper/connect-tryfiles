expect = require('chai').expect
tryfiles = require '../index'
connect = require 'connect'
http = require 'http'
request = require 'request'
require 'colors'

remoteApp = connect().use (req, res, next) -> res.end('qux')
remoteServer = http.createServer(remoteApp)
server = undefined
app = undefined

startServer = (app) ->
  console.log '\tlistening on 8000'.blue
  server = http.createServer(app).listen(8000)

describe 'Try Files', ->

  beforeEach ->
    console.log '\tlistening on 9000'.blue
    app = connect()
    remoteServer.listen(9000)

  afterEach ->
    console.log '\tclosing 9000'.red
    remoteServer.close()
    console.log '\tclosing 8000'.red
    server.close()

  it 'should respond with local file', (done) ->
    app.use tryfiles 'specs/fixtures/**', 'http://localhost:9000'
    app.use connect.static 'specs/fixtures/'
    startServer app

    request 'http://localhost:8000/foo', (err, response, body) ->
      return done err if err
      expect(body).to.equal('bar')
      done()

  it 'should respond with local file respecting cwd', (done) ->
    app.use tryfiles '**', 'http://localhost:9000', {cwd: 'specs/fixtures'}
    app.use connect.static 'specs/fixtures/'
    startServer app

    request 'http://localhost:8000/foo', (err, response, body) ->
      return done err if err
      expect(body).to.equal('bar')
      done()

  it 'should respond via proxy', (done) ->
    app.use tryfiles 'specs/fixtures/**', 'http://localhost:9000'
    app.use connect.static 'specs/fixtures/'
    startServer app

    request 'http://localhost:8000/qux', (err, response, body) ->
      return done err if err
      expect(body).to.equal('qux')
      done()

  it 'should respond via proxy respecting proxy options', (done) ->
    app.use tryfiles 'specs/fixtures/**', {target: 'http://localhost:9000'}
    app.use connect.static 'specs/fixtures/'
    startServer app

    request 'http://localhost:8000/qux', (err, response, body) ->
      return done err if err
      expect(body).to.equal('qux')
      done()