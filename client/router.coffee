
taskRounds  = null
taskChat    = null
taskAnswers = null

tutorialRounds  = null
tutorialChat    = null
tutorialAnswers = null

Router.map ->
  @route "homepage",
    path: "/"
  @route "tutorial",
    before: ->
      tutorialRounds = Meteor.subscribe("rounds", "tutorial")
      tutorialChat = Meteor.subscribe("chatMessages", "tutorial")
      tutorialAnswers = Meteor.subscribe("answers", "tutorial")
    unload: ->
      tutorialRounds.stop()
      tutorialChat.stop()
      tutorialAnswers.stop()
  @route "quiz"
  @route "task",
    before: ->
      taskRounds = Meteor.subscribe("rounds", "task")
      taskChat = Meteor.subscribe("chatMessages", "task")
      taskAnswers = Meteor.subscribe("answers", "task")
    after: ->
#      Template.timerFirst.startTimerFirst()
    unload: ->
      console.log "task unload called"
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

