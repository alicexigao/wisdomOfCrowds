Template.quiz.events =
  "click #goToTutorial": (ev) ->

    Meteor.Router.to("/tutorial")

  "click #submitAnswers": (ev) ->

    checkedIds = []
    $('input:checkbox:checked').each ->
      checkedIds.push $(this).attr('id')

    data =
      userId: Meteor.user()._id
      list: checkedIds

    Meteor.call "gradeQuiz", data, (error, result) ->
      if error
        return bootbox.alert error.reason
      else if result is false
        # failed quiz
        return bootbox.alert ErrorMessages.findOne({type: "quiz"}).message
      else
        data =
          userId: Meteor.user()._id
        Meteor.call "setStatusReady", data, (error, result) ->
          if error
            return bootbox.alert error.reason
          else if result is true
            Meteor.Router.to('/task')
          else
            Meteor.Router.to("/lobby")


Template.quiz.getQuizError = ->
  if ErrorMessages.findOne({userId: Meteor.user()._id, type: "quiz"})
    return ErrorMessages.findOne({userId: Meteor.user()._id, type: "quiz"}).message
  else return ""

Template.quiz.hasError = ->
  return ErrorMessages.findOne({userId: Meteor.user()._id, type: "quiz"})
