Template.taskHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.taskHistory.isRoundFinished = (index) ->
  currRoundIndex = Util.getRoundIndex()
  if index < currRoundIndex
    return true
  else if index is currRoundIndex
    if Util.answersFinalized()
      return true
  return false

Template.taskHistory.getRoundIndexDisplay = ->
  return this.index

Template.taskHistory.getCorrectAnswer = ->
  questionId = this.questionId
  Meteor.subscribe "correctAnswer", questionId
  answer = Settings.findOne({_id: questionId}).answer
  return answer + "%"

Template.taskHistory.getMyAnswerString = ->
  currUserId = Util.getCurrUserId()
  ansObj =
    Answers.findOne {roundIndex: @index, userId: currUserId}
  return unless ansObj
  return ansObj.answer + "%"

Template.taskHistory.getBestAnswerString = ->
  best = parseInt(this.best * 100, 10) / 100
  return best + "%"

Template.taskHistory.getAverageString = ->
  avg = parseInt(this.average * 100, 10) / 100
  return avg + "%"

Template.taskHistory.calcPoints = ->
  return unless (tre = TurkServer.treatment())

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
    pts = Template.taskHistory.getPoints(this.average, correctAnswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

Template.taskHistory.getPoints = (ans, correct) ->
  if Math.abs(ans - correct) > 50
    return 10
  else
    return 110 - 2 * Math.abs(ans - correct)
