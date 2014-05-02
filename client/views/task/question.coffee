Template.roundQuestion.getRoundIndexDisplay = ->
  Util.getRoundIndex()

Template.roundQuestion.getQuestion = ->
  roundObj = Util.getCurrRoundObj()
  return unless roundObj
  questionId = roundObj.questionId
  Settings.findOne({_id: questionId}).value

Template.roundQuestion.numRounds = ->
  Rounds.find().count()

Template.roundQuestion.hasActiveRound = ->
  TurkServer.currentRound()?