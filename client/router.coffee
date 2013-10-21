Router.map ->
  @route "homepage",
    path: "/"
  @route "tutorial"
  @route "quiz"
  @route "lobby"
  @route "task"
  @route "exitsurvey"
  @route "admin"


Deps.autorun ->
  state = Session.get("turkserver.state")
  return unless state

  if state is "quiz"
    Router.go("/")
  else if state is "lobby"
    Router.go("/lobby")
  else if state is "experiment"
    Router.go("/task")


