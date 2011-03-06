mongoose = require 'mongoose'

######################
# User
######################
User = new mongoose.Schema
  email:
    type: String
    unique: true
    set: this.toLower
  hashed_password:
    type: String
    set: this.encryptPassword
  salt: String,
  stacks: [Stack]

User.method 'toLower', (email) ->
  return email.toLowerCase()

User.method 'toLower', (email) ->
  return email.toLowerCase()

User.method 'authenticate', (plainText) ->
  return this.encryptPassword(plainText) is this.hashed_password

User.method 'makeSalt', ->
  return Math.round(new Date().valueOf() * Math.random()) + ''

User.method 'encryptPassword', (password) ->
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex')

######################
# Stack
######################
Stack = new mongoose.Schema
  # order in which to show stacks
  next_appearance: Number
  flashcards: [Flashcard]

######################
# Flashcard
######################
Flashcard = new mongoose.Schema
  # Foreign key to question
  question: String
  # answers are embedded documents
  answers: [Answer]

######################
# Answer
######################
Answer = new mongoose.Schema
  # how the user rated his response
  rating: Number
  # answer text (not sure how this will be formatted for matching)
  answer: String

######################
# Question
######################
Question = new mongoose.Schema
  # question text
  question: String
  # type could be free response or matching
  type: String
  # page number in First Aid book
  page_number: Number
  # medical topic area
  topic: String

mongoose.model 'User', User
mongoose.model 'Stack', Stack
mongoose.model 'Flashcard', Flashcard
mongoose.model 'Answer', Answer
mongoose.model 'Question', Question

exports.User = mongoose.model('User')
exports.Stack = mongoose.model('Stack')
exports.Flashcard = mongoose.model('Flashcard')
exports.Answer = mongoose.model('Answer')
exports.Question = mongoose.model('Question')