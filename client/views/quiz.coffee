Template.quiz.events =
  "click #goToTutorial": (ev) ->

    Router.go("/tutorial")

  "click #submitAnswers": (ev) ->

    checkedIds = []
    $('input:checkbox:checked').each ->
      checkedIds.push $(this).attr('id')

    data =
      userId: Meteor.userId()
      list: checkedIds

    Meteor.call "gradeQuiz", data, (error, result) ->
      if error
        return bootbox.alert error.reason
      else if result is false
        # failed quiz
        return bootbox.alert ErrorMessages.findOne({type: "quiz"}).message
      else
        data =
          userId: Meteor.userId()
        Meteor.call "setStatusReady", data, (error, result) ->
          if error
            return bootbox.alert error.reason
          else if result is true
            Router.go('/task')
          else
            Router.go("/lobby")


Template.quiz.getQuizError = ->
  if ErrorMessages.findOne({userId: Meteor.userId(), type: "quiz"})
    return ErrorMessages.findOne({userId: Meteor.userId(), type: "quiz"}).message
  else return ""

Template.quiz.hasError = ->
  return ErrorMessages.findOne({userId: Meteor.userId(), type: "quiz"})
