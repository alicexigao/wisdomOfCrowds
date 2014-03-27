Template.question.getRoundIndexDisplay = ->
  Util.getRoundIndex() + 1

Template.question.getQuestion = ->
  roundObj = Util.getCurrRoundObj()
  questionId = roundObj.questionId
  Settings.findOne({_id: questionId}).value

Template.question.numRounds = ->
  Rounds.find().count()

Template.question.hasActiveRound = ->
  Rounds.find({active: true}).count() > 0