
taskQuestions = null
taskRounds  = null
taskChat    = null
taskAnswers = null

tutorialQuestions = null
tutorialRounds  = null
tutorialChat    = null
tutorialAnswers = null

userSub = null
treatment = null

Router.configure({
#  layoutTemplate: 'layout',
#  notFoundTemplate: 'notFound',
  loadingTemplate: 'loading'
});

Deps.autorun ->
  group = TurkServer.group()
  # Need to resubscribe to users whenever group changes
  userSub = Meteor.subscribe "users", group

  Meteor.subscribe "chatMessages"

Meteor.subscribe "errorMessages"

# Get the data for the current treatment name
Deps.autorun ->
  treatment = TurkServer.treatment()
  return unless treatment
  Meteor.subscribe("treatment", treatment)

Router.map ->
  @route "homepage",
    path: "/"
  @route "tutorial",
    waitOn: ->
      tutorialQuestions = Meteor.subscribe "settingsTutorialQuestions"
      tutorialRounds = Meteor.subscribe("rounds", "tutorial")
      tutorialChat = Meteor.subscribe("chatMessages", "tutorial")
      tutorialAnswers = Meteor.subscribe("answers", "tutorial")
      return [tutorialQuestions, treatment, tutorialRounds, tutorialChat, tutorialAnswers]
    unload: ->
      tutorialQuestions.stop()
      tutorialRounds.stop()
      tutorialChat.stop()
      tutorialAnswers.stop()
  @route "quiz"
  @route "task",
    waitOn: ->
      TurkServer.group()
      taskQuestions = Meteor.subscribe "settingsTaskQuestions"
      taskRounds = Meteor.subscribe("rounds", "task")
      taskChat = Meteor.subscribe("chatMessages", "task")
      taskAnswers = Meteor.subscribe("answers", "task")
      return [taskQuestions, taskRounds, taskChat, taskAnswers]
    before: ->
    after: ->
    unload: ->
      taskQuestions.stop()
      taskRounds.stop()
      taskChat.stop()
      taskAnswers.stop()
  @route "exitsurvey"

# Auto routing for state
Deps.autorun -> Router.go("/") if TurkServer.inQuiz()

Deps.autorun ->
  if TurkServer.inExperiment()
    groupId = TurkServer.group()
    Router.go("/task")
    Meteor.call "saveStartTime", groupId


