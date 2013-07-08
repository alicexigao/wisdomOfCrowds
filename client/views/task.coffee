Template.taskCompleted.events =

  "click #goToExitSurvey": (ev) ->
    Meteor.Router.to('/exitsurvey')

Template.task.isTaskCompleted = ->
  numQuestions = Rounds.find().count()

  round =  Rounds.findOne({index: numQuestions - 1})
  if round
    if round.status is "completed"
      Meteor.clearInterval(Template.timerNext.intervalIdNext)
      Meteor.clearInterval(Template.timerMain.intervalIdMain)
      return true
  return false
