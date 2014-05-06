glob = require 'glob'
path = require 'path'
_ = require 'underscore'
httpProxy = require 'http-proxy'
require 'colors'

module.exports = (match, target, options = {})->
  console.verbose = -> console.log.apply(console, arguments) if options.verbose
    
  options.index = 'index.html' if options.index is undefined
    
  globOptions =
    nosort: true
    mark: true

  proxyOptions = if typeof target is 'string' then {target: target} else target

  proxy = httpProxy.createProxyServer proxyOptions

  (req, res, next) ->
    glob match, _.extend(globOptions, options), (err, files = []) ->
      next err if err

      cleanUrl = req.url.replace(/\?.*/, '').replace(/^\//,'').replace(/\/$/,'')

      foundFiles = files
        # Excludes directories
        .filter((f) -> f.charAt(f.length-1) isnt '/')
        # Match with url ignoring query string
        .filter((f) -> 
          f is cleanUrl)
      
      foundDirectories = files
        # Excludes files
        .filter((f) -> f.charAt(f.length-1) is '/')
        # Match with url ignoring query string
        .filter((f) ->
          f.replace(/^\//, '').replace(/\/$/,'') is cleanUrl)

      if foundFiles.length > 0
        console.verbose "Found file:", foundFiles.toString().green
        return next()
        
      # If directory was found, search for index
      if options.index and foundDirectories.length > 0
        # replace first slash, if present, or glob can't find the file.
        indexPath = path.join(foundDirectories[0], options.index)
        index = glob.sync path.join(indexPath), _.extend(globOptions, options)
        console.verbose "Found file:", index.toString().green
        return next() if index
        
      console.verbose "Proxying:", req.url.cyan
      proxy.web req, res, (err) ->
        next err if err
