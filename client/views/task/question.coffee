
Template.question.getRoundIndexDisplay = ->
  Handlebars._default_helpers.getRoundIndex() + 1

Template.question.getQuestion = ->
  questionId = Handlebars._default_helpers.getCurrRoundObj().questionId
  Settings.findOne({_id: questionId}).value

