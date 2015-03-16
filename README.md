connect-tryfiles
================

# WARNING: DEPRECATED

This was a nice experiment, but right now there is a better way to accomplish the same.

As the new `serve-static` middleware from Express now calls `next` when it doesn't find a file, you can simply add a proxy afterwards:

    connect = require 'connect'
    http = require 'http'
    serveStatic = require('serve-static')
    proxy = require('proxy-middleware')

    app = connect()
        .use(serveStatic('./files'))
        .use(proxy(url.parse('https://example.com/endpoint')))

    server = http.createServer(app).listen(8000)

Here be dragons! You have been warned :)

### Description

![Build status](https://travis-ci.org/firstdoit/connect-tryfiles.png)

nginx try_files style connect middleware: serve local file if exists or proxy to address

### Idea

If a local file is available at the path corresponding to the URL, this middleware will do nothing (giving the chance to some other middleware serve it).
Else, it will proxy the request to the given target.
This way, you can serve local files easily and proxy the rest to your remote server.

### Usage

    connect = require 'connect'
    http = require 'http'
    tryfiles = require 'connect-tryfiles'

    app = connect()
        .use(tryfiles('**', 'http://localhost:9000', {cwd: 'files'}))
        .use(connect.static('./files'))

    server = http.createServer(app).listen(8000)

Assuming there is

- a file at `./files/foo`
- a different server listening at localhost:9000 that returns "world" to any request

Requests to:

- `http://localhost:8000/foo` will retrieve the file at `files/foo`
- `http://localhost:8000/hello` will return "world"
