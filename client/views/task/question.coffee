
Template.question.getRoundIndexDisplay = ->
  Handlebars._default_helpers.getRoundIndex() + 1

Template.question.getQuestion = ->
  roundObj = Handlebars._default_helpers.getCurrRoundObj()
  questionId = roundObj.questionId
  Settings.findOne({_id: questionId}).value

