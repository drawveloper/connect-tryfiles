glob = require 'glob'
_ = require 'underscore'
httpProxy = require 'http-proxy'
require 'colors'

module.exports = (match, target, options = {})->
  console.verbose = -> console.log.apply(console, arguments) if options.verbose
    
  globOptions =
    nosort: true
    mark: true

  proxyOptions = if typeof target is 'string' then {target: target} else target

  proxy = httpProxy.createProxyServer proxyOptions

  (req, res, next) ->
    glob match, _.extend(globOptions, options), (err, files = []) ->
      next err if err

      found = files
        # Excludes directories
        .filter((f) -> f.charAt(f.length-1) isnt '/')
        # Match with url ignoring query string
        .filter((f) ->
          f is req.url.slice(1).replace(/\?.*/, ''))

      if found.length > 0
        console.verbose "Found file:", found.toString().green
        next()
      else
        console.verbose "Proxying:", req.url.cyan
        proxy.web req, res, (err) ->
          next err if err
