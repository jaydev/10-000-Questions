mongoose = require 'mongoose'

Schema = mongoose.Schema

######################
# User
######################
UserSchema = new Schema
  created_on:
    type: Date
    default: Date.now
  email:
    type: String
    unique: true
    set: (email) ->
      return email.toLowerCase()
  hashed_password:
    type: String
    #set: this.encryptPassword
  salt: String
  orders: [OrderSchema]
  stacks: [StackSchema]
  stack_number:
    type: Number
    default: 0
  card_number:
    type: Number
    default: 0

UserSchema.method 'toLower', (email) ->
  return email.toLowerCase()

UserSchema.method 'authenticate', (plainText) ->
  return this.encryptPassword(plainText) is this.hashed_password

UserSchema.method 'makeSalt', ->
  return Math.round(new Date().valueOf() * Math.random()) + ''

UserSchema.method 'encryptPassword', (password) ->
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex')

UserSchema.method 'createStacks', (user, fn) ->
  # Initialize stacks and flashcards.
  # This method should only ever be called once for this user.
  # TODO: Raise error if user has stacks/cards assigned already.
  Flashcard.find {}, (err, cards) ->
    stack = new Stack
      position: 0
    for card in cards
      flashcard = new Flashcard
        stack_id: stack._id
        position: card.position
        question: card.question
        type: card.type
        page_number: card.page_number
        topic: card.topic
      flashcard.save()
    user.stacks.push stack
    user.save()
    fn user

UserSchema.method 'getCurrentStack', (user) ->
  for stack in user.stacks
    # We have to cast here because stack_number is an Object
    # and position is a Number.
    if Number(stack.position) is Number(user.stack_number)
      return stack

UserSchema.method 'getCurrentFlashcard', (user, fn) ->
  stack = user.getCurrentStack user
  filter_params = {stack_id: stack._id, position: user.card_number}
  Flashcard.findOne filter_params, (err, card) ->
    fn card

######################
# Order
######################
OrderSchema = new Schema
  product: String
  created_on:
    type: Date
    default: Date.now

######################
# Stack
######################
StackSchema = new Schema
  position: Number

######################
# Flashcard
######################
FlashcardSchema = new Schema
  position: Number
  stack_id: Schema.ObjectId
  # question text
  question: String
  # type could be free response or matching
  type: String
  # page number in First Aid book
  page_number: Number
  # medical topic area
  topic: String
  answers: [AnswerSchema]

######################
# Answer
######################
AnswerSchema = new Schema
  created_on:
    type: Date
    default: Date.now
  # how the user rated his response
  rating: Number
  # answer text (not sure how this will be formatted for matching)
  answer: String

mongoose.model 'Answer', AnswerSchema
mongoose.model 'Flashcard', FlashcardSchema
mongoose.model 'Order', OrderSchema
mongoose.model 'Stack', StackSchema
mongoose.model 'User', UserSchema

exports.Answer = Answer = mongoose.model 'Answer'
exports.Flashcard = Flashcard = mongoose.model 'Flashcard'
exports.Order = Order = mongoose.model 'Order'
exports.Stack = Stack = mongoose.model 'Stack'
exports.User = User = mongoose.model 'User'