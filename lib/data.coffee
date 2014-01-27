@Settings = new Meteor.Collection('settings')

@Treatment = new Meteor.Collection('treatment')

@Rounds = new Meteor.Collection('rounds')
@Answers = new Meteor.Collection('answers')
@ChatMessages = new Meteor.Collection('chatMessages')

@QuizAttempts = new Meteor.Collection('quizAttempts')
@ErrorMessages = new Meteor.Collection('errorMessages')

if Meteor.isServer
  TurkServer.partitionCollection ChatMessages
  TurkServer.partitionCollection Answers
  TurkServer.partitionCollection Rounds
