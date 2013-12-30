
taskQuestions = null
taskRounds  = null
taskChat    = null
taskAnswers = null

tutorialQuestions = null
tutorialRounds  = null
tutorialChat    = null
tutorialAnswers = null

treatment = null

Router.configure({
#  layoutTemplate: 'layout',
#  notFoundTemplate: 'notFound',
  loadingTemplate: 'loading'
});

Router.map ->
  @route "homepage",
    path: "/"
  @route "tutorial",
    waitOn: ->
      tutorialQuestions = Meteor.subscribe "settingsTutorialQuestions"
      users = Meteor.subscribe("users")
      treatment = Meteor.subscribe("treatment")
      tutorialRounds = Meteor.subscribe("rounds", "tutorial")
      tutorialChat = Meteor.subscribe("chatMessages", "tutorial")
      tutorialAnswers = Meteor.subscribe("answers", "tutorial")
      return [tutorialQuestions, users, treatment, tutorialRounds, tutorialChat, tutorialAnswers]
    unload: ->
      tutorialQuestions.stop()
      tutorialRounds.stop()
      tutorialChat.stop()
      tutorialAnswers.stop()
  @route "quiz"
  @route "task",
    waitOn: ->
      taskQuestions = Meteor.subscribe "settingsTaskQuestions"
      users = Meteor.subscribe("users")
      treatment = Meteor.subscribe("treatment")
      taskRounds = Meteor.subscribe("rounds", "task")
      taskChat = Meteor.subscribe("chatMessages", "task")
      taskAnswers = Meteor.subscribe("answers", "task")
      return [taskQuestions, users, taskRounds, taskChat, taskAnswers]
    before: ->
    after: ->
    unload: ->
      taskQuestions.stop()
      taskRounds.stop()
      taskChat.stop()
      taskAnswers.stop()
  @route "exitsurvey"
  @route "admin"

Deps.autorun ->
  state = Session.get("turkserver.state")
  return unless state

  if state is "quiz"
    Router.go("/")
  else if state is "lobby" # This route is defined by turkserver
    Router.go("/lobby")
  else if state is "experiment"
    Router.go("/task")

