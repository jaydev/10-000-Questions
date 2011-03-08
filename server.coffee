# Node standard libraries
crypto = require 'crypto'
sys = require 'sys'
url = require 'url'
path = require 'path'
fs = require 'fs'

# Third party
require.paths.push '/usr/local/lib/node'
coffeekup = require 'coffeekup'
express = require 'express'
mongoose = require 'mongoose'
mongoStore = require 'connect-mongodb'

models = require './models'

# Globals
HOST = 'localhost'
PORT = '8080'
SITE_ROOT = process.cwd() + '/'

server = express.createServer()

## Configure server and middleware options

server.configure ->
  server.set 'views', __dirname + '/templates'
  server.set 'partials', __dirname + '/templates'
  server.register '.coffee', coffeekup
  server.set 'view engine', 'coffee'
  server.use express.logger()
  # For parsing request bodies (form POSTs, etc.)
  server.use express.bodyDecoder()
  # These must come after bodyDecoder and before methodOverride
  server.use express.cookieDecoder()
  # Must come after bodyDecoder
  server.use express.methodOverride()
  # Static media directory
  server.use express.staticProvider __dirname
  server.use server.router

server.configure 'development', ->
  # Show verbose page errors
  server.use express.errorHandler
    dumpExceptions: true
    showStack: true
  # Connect to database `test`
  db_url = 'mongodb://localhost:27017/test'
  # Use MongoDB as a session store
  server.use express.session
    key: 'a key',
    secret: 'secrets are no fun!'
    store: mongoStore
      url: db_url
  mongoose.connect db_url

server.configure 'production', ->
  express.errorHandler()

## Helpers

loadUser = (req, res, next) ->
  if req.session.user_id
    User.findById req.session.user_id, (user) ->
      if user
        req.currentUser = user
        next()
      else
        res.redirect '/sessions/new'
  else
      res.redirect '/sessions/new'

## Routes

server.get '/', (req, res) ->
  res.render 'layout',
    context:
      title: 'Home'
      content: res.partial 'home'

server.get '/about', (req, res) ->
  res.render 'layout',
    locals:
      title: 'About',
      content: res.partial 'about'

#server.get '/dashboard', loadUser, (req, res) ->

server.get '/flashcards', (req, res) ->
  # Select a question at random
  Question = models.Question
  Question.count {}, (err, docs) ->
    num_qs = docs
    Question.find {}, (err, docs) ->
      rand_int = Math.floor(Math.random() * num_qs)
      question = docs[rand_int]
      res.render 'layout',
        locals:
          title: 'Flashcards',
          content: res.partial 'flashcards'
            object: res.partial 'answer'
              object: question
              as: 'question'
            as: 'flashcard_content'

server.post '/flashcards/next', (req, res) ->
  res.render 'rate',
    layout: false

## Start the server

server.listen PORT, HOST
sys.puts "Server running at #{HOST}:#{PORT}"