
Template.question.getRoundIndexDisplay = ->
  Handlebars._default_helpers.getRoundIndex() + 1

# TODO: randomize order of questions
Template.question.getQuestion = ->
  Handlebars._default_helpers.getRoundObj().question

Template.question.numRounds = ->
  Rounds.find().count()

