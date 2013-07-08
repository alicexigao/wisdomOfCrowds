Template.quiz.events =
  "click #goToTutorial": (ev) ->
    Meteor.Router.to("/tutorial")

  "click #submitAnswers": (ev) ->
    Meteor.Router.to("/task")

#    Meteor.call 'startTimerMain', {}, (error, id) ->
#      if error
#        return bootbox.alert error.reason