# Node standard libraries
sys = require "sys"
url = require "url"
path = require "path"
fs = require "fs"

# Third party
require.paths.push '/usr/local/lib/node'
express = require 'express'
jade = require 'jade'

# Globals
HOST = "localhost"
PORT = "8080"
SITE_ROOT = process.cwd() + '/'

server = express.createServer()

## Configure server and middleware options

server.configure ->
  server.set 'views', __dirname
  server.set 'partials', __dirname
  server.set 'view engine', 'jade'
  server.use express.logger()
  # For parsing request bodies (form POSTs, etc.)
  server.use express.bodyDecoder()
  # Must come after bodyDecoder
  server.use express.methodOverride()
  # Static media directory
  server.use express.staticProvider __dirname
  server.use server.router

server.configure 'development', ->
  # Show verbose page errors
  server.use express.errorHandler {
    dumpExceptions: true,
    showStack: true
  }

server.configure 'production', ->
  express.errorHandler()

## Routes

server.get '/', (req, res) ->
  res.render 'layout',
    locals: {
      title: 'Home',
      content: res.partial 'home'
    }

server.get '/about', (req, res) ->
  res.render 'layout',
    locals: {
      title: 'About',
      content: res.partial 'about'
    }

## Start the server

server.listen PORT, HOST
sys.puts "Server running at #{HOST}:#{PORT}"