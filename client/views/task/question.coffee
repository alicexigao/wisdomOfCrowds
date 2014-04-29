Template.question.getRoundIndexDisplay = ->
  Util.getRoundIndex()

Template.question.getQuestion = ->
  roundObj = Util.getCurrRoundObj()
  return unless roundObj
  questionId = roundObj.questionId
  Settings.findOne({_id: questionId}).value

Template.question.numRounds = ->
  Rounds.find().count()

Template.question.hasActiveRound = ->
  TurkServer.currentRound()?