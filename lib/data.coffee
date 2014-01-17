@Treatment = new Meteor.Collection('treatment')

@Settings = new Meteor.Collection('settings')

@Rounds = new Meteor.Collection('rounds')

@Answers = new Meteor.Collection('answers')

@ChatMessages = new Meteor.Collection('chatMessages')

@QuizAttempts = new Meteor.Collection('quizAttempts')
@ErrorMessages = new Meteor.Collection('errorMessages')
@Timers = new Meteor.Collection("timeleft")

if Meteor.isServer
  TurkServer.registerCollection Treatment
  TurkServer.registerCollection ChatMessages