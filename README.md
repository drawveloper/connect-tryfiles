connect-tryfiles
================

![Build status](https://travis-ci.org/gadr/connect-tryfiles.png)

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
