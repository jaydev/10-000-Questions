# Node standard libraries
crypto = require 'crypto'
sys = require 'sys'
url = require 'url'
path = require 'path'
fs = require 'fs'

# Third party
coffeekup = require 'coffeekup'
express = require 'express'
mongoose = require 'mongoose'
mongoStore = require 'connect-mongodb'

# App
Answer = require('./models').Answer
Flashcard = require('./models').Flashcard
User = require('./models').User
partials = require './templates/partials'

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
  server.use express.bodyParser()
  # These must come after bodyDecoder and before methodOverride
  server.use express.cookieParser()
  # Must come after bodyDecoder
  server.use express.methodOverride()
  # Static media directory
  server.use express.static __dirname
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

getOrCreateUser = (req, res, next) ->
  User.findOne {}, (err, user) ->
    if not user
      user = new User
        email: 'jaydevm@gmail.com'
      user.save()
      user.createStacks user, (user) ->
        req.currentUser = user
        next()
    else
      req.currentUser = user
      next()

## Routes

server.get '/', (req, res) ->
  res.render 'layout',
    context:
      title: 'Home'
      content: coffeekup.render partials.home

server.get '/about', (req, res) ->
  res.render 'layout',
    context:
      title: 'About',
      content: coffeekup.render partials.about

#server.get '/dashboard', loadUser, (req, res) ->

server.get '/flashcards', getOrCreateUser, (req, res) ->
  user = req.currentUser
  user.getCurrentFlashcard user, (card) ->
    res.render 'layout',
      context:
        title: 'Flashcards',
        content: coffeekup.render(
          partials.flashcards,
          context:
            content: coffeekup.render(
              partials.answer,
              context:
                card: card
            )
        )

server.get '/flashcards/rate', getOrCreateUser, (req, res) ->
  res.send coffeekup.render partials.rate

server.post '/flashcards', getOrCreateUser, (req, res) ->
  user = req.currentUser
  user.getCurrentFlashcard user, (card) ->
    if req.body.answer
      # Create a new Answer
      if not card.answers
        card.answers = new Array()
      answer = new Answer
        answer: req.body.answer
        rating: req.body.rating
      card.answers.push answer
      card.save()
      res.send coffeekup.render partials.rate
    else if req.body.rating
      # Add a rating to the last submitted Answer
      # Doesn't work due to atomic save issue with mongoose
      num_answers = card.answers.length
      card.answers[num_answers-1].rating = req.body.rating
      card.save()
      user.getNextFlashcard user, (card) ->
        res.render 'layout',
          context:
            title: 'Flashcards',
            content: coffeekup.render(
              partials.flashcards,
              context:
                content: coffeekup.render(
                  partials.answer,
                  context:
                    card: card
                )
            )

## Start the server

server.listen PORT, HOST
sys.puts "Server running at #{HOST}:#{PORT}"