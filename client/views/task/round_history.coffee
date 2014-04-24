Template.roundHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.roundHistory.isRoundFinished = (index) ->
  currRoundIndex = Util.getRoundIndex()
  if index < currRoundIndex
    return true
  else if index is currRoundIndex
    if Util.answersFinalized()
      return true
  return false

Template.roundHistory.getRoundIndexDisplay = ->
  return this.index + 1

Template.roundHistory.getCorrectAnswer = ->
  questionId = this.questionId
  Meteor.subscribe "correctAnswer", questionId
  answer = Settings.findOne({_id: questionId}).answer
  return answer + "%"

Template.roundHistory.getMyAnswerString = ->
  currUserId = Util.getCurrUserId()
  ansObj =
    Answers.findOne {roundIndex: @index, userId: currUserId}
  return unless ansObj
  return ansObj.answer + "%"

Template.roundHistory.getBestAnswerString = ->
  best = parseInt(this.best * 100, 10) / 100
  return best + "%"

Template.roundHistory.getAverageString = ->
  avg = parseInt(this.average * 100, 10) / 100
  return avg + "%"

Template.roundHistory.calcPoints = ->
  return unless (tre = Util.tre())
  #  tre = Util.tre()
  userId = Util.getCurrUserId()

  if tre.rewardRule is "best"

    return "" unless this.bestAnsUserIds

    if this.bestAnsUserIds.indexOf(userId) >= 0
      pts = 100 / this.bestAnsUserIds.length
      pts = Math.floor(pts)
      return pts
    else
      return 10

  else if tre.rewardRule is "average"

    correctAnswer = Settings.findOne({_id: this.questionId}).answer
    pts = Template.roundHistory.getPoints(this.average, correctAnswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

Template.roundHistory.getPoints = (ans, correct) ->
  if Math.abs(ans - correct) > 50
    return 10
  else
    return 110 - 2 * Math.abs(ans - correct)
