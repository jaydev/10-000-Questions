mongoose = require 'mongoose'

Schema = mongoose.Schema

######################
# User
######################
UserSchema = new Schema
  email:
    type: String
    unique: true
    set: this.toLower
  hashed_password:
    type: String
    set: this.encryptPassword
  salt: String
  orders: [OrderSchema]
  stacks: [StackSchema]

UserSchema.method 'toLower', (email) ->
  return email.toLowerCase()

UserSchema.method 'authenticate', (plainText) ->
  return this.encryptPassword(plainText) is this.hashed_password

UserSchema.method 'makeSalt', ->
  return Math.round(new Date().valueOf() * Math.random()) + ''

UserSchema.method 'encryptPassword', (password) ->
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex')

UserSchema.method 'createStacks', (user) ->
  Question.find {}, (err, questions) ->
    stack = new Stack
      position: 1
    stack.save()
    card_pos = 1
    for question in questions
      stack.flashcards.push
        position: card_pos,
        question_id: question._id
      card_pos += 1
    user.stacks.push stack
    user.save()

######################
# Order
######################
OrderSchema = new Schema
  product: String
  created_on: Date

######################
# Stack
######################
StackSchema = new Schema
  position: Number
  flashcards: [FlashcardSchema]

######################
# Flashcard
######################
FlashcardSchema = new Schema
  position: Number
  question_id: Schema.ObjectId
  answers: [AnswerSchema]

######################
# Answer
######################
AnswerSchema = new Schema
  created_on: Date
  # how the user rated his response
  rating: Number
  # answer text (not sure how this will be formatted for matching)
  answer: String

######################
# Question
######################
QuestionSchema = new Schema
  # question text
  question: String
  # type could be free response or matching
  type: String
  # page number in First Aid book
  page_number: Number
  # medical topic area
  topic: String

mongoose.model 'User', UserSchema
mongoose.model 'Order', OrderSchema
mongoose.model 'Stack', StackSchema
mongoose.model 'Flashcard', FlashcardSchema
mongoose.model 'Answer', AnswerSchema
mongoose.model 'Question', QuestionSchema

exports.User = User = mongoose.model 'User'
exports.Order = Order = mongoose.model 'Order'
exports.Stack = Stack = mongoose.model 'Stack'
exports.Flashcard = Flashcard = mongoose.model 'Flashcard'
exports.Answer = Answer = mongoose.model 'Answer'
exports.Question = Question = mongoose.model 'Question'