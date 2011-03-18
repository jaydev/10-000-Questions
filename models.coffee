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
  salt: String
  orders: [Order]
  stacks: [Stack]

User.method 'toLower', (email) ->
  return email.toLowerCase()

User.method 'authenticate', (plainText) ->
  return this.encryptPassword(plainText) is this.hashed_password

User.method 'makeSalt', ->
  return Math.round(new Date().valueOf() * Math.random()) + ''

User.method 'encryptPassword', (password) ->
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex')

######################
# Order
######################
Order = new mongoose.Schema
  product: String
  created_on: Date

######################
# Stack
######################
Stack = new mongoose.Schema
  # order in which to show stacks
  position: Number
  flashcards: [Flashcard]

######################
# Flashcard
######################
Flashcard = new mongoose.Schema
  position: Number
  question_id: String
  answers: [Answer]

######################
# Answer
######################
Answer = new mongoose.Schema
  created_on: Date
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
mongoose.model 'Order', Order
mongoose.model 'Stack', Stack
mongoose.model 'Flashcard', Flashcard
mongoose.model 'Answer', Answer
mongoose.model 'Question', Question

exports.User = mongoose.model 'User'
exports.Order = mongoose.model 'Order'
exports.Stack = mongoose.model 'Stack'
exports.Flashcard = mongoose.model 'Flashcard'
exports.Answer = mongoose.model 'Answer'
exports.Question = mongoose.model 'Question'