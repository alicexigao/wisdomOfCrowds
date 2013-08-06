Meteor.Router.add({
    '/'         : 'homepage',
    '/tutorial' : 'tutorial',
    '/quiz'     : 'quiz',
    '/lobby'    : 'lobby',
    '/task'     : 'task',
    '/exitsurvey' : "exitsurvey",
    '/admin':   "admin"
})

Deps.autorun ->
  state = Session.get("turkserver.state")
  return unless state

  if state is "quiz"
    Meteor.Router.to("/")
  else if state is "lobby"
    Meteor.Router.to("/lobby")
  else if state is "experiment"
    Meteor.Router.to("/task")
