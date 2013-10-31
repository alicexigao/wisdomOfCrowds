
Router.map ->
  @route "homepage",
    path: "/"
  @route "tutorial",
    before: ->
      @tutorialRounds = @subscribe("rounds", "tutorial")
      @tutorialChat = @subscribe("chatMessages", "tutorial")
      @tutorialAnswers = @subscribe("answers", "tutorial")
    unload: ->
      @tutorialRounds.stop()
      @tutorialChat.stop()
      @tutorialAnswers.stop()
  @route "quiz"
  @route "task",
    before: ->
      @taskRounds = @subscribe("rounds", "task").wait()
      @taskChat = @subscribe("chatMessages", "task").wait()
      @taskAnswers = @subscribe("answers", "task")
    after: ->
#      Template.timerFirst.startTimerFirst()
    unload: ->
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

