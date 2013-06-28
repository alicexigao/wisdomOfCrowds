Template.taskCompleted.events =

  "click #goToExitSurvey": (ev) ->
    Meteor.Router.to('/exitsurvey')

Template.task.isTaskCompleted = ->
  numQuestions = Rounds.find().count()

  round =  Rounds.findOne({index: numQuestions - 1})
  if round
    return round.status is "completed"
  return false
