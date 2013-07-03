Template.quiz.events =
  "click #goToTutorial": (ev) ->
    Meteor.Router.to("/tutorial")

  "click #submitAnswers": (ev) ->
    Meteor.Router.to("/task")