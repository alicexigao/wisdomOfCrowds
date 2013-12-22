Template.roundHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.roundHistory.isRoundFinished = (index) ->
  currRoundIndex = Handlebars._default_helpers.getRoundIndex()
  if index < currRoundIndex
    return true
  else if index is currRoundIndex
    if Handlebars._default_helpers.answersFinalized()
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
  currUserId = Handlebars._default_helpers.currUserId()
  ansObj = Handlebars._default_helpers.ansObjForIndexId(@index, currUserId)
  return unless ansObj
  return ansObj.answer + "%"

Template.roundHistory.showBestAns = ->
  tre = Handlebars._default_helpers.tre()
  tre.showBestAns

Template.roundHistory.showAvg = ->
  tre = Handlebars._default_helpers.tre()
  tre.showAvg

Template.roundHistory.getBestAnswerString = ->
  best = parseInt(this.best * 100, 10) / 100
  return best + "%"

Template.roundHistory.getAverageString = ->
  avg = parseInt(this.average * 100, 10) / 100
  return avg + "%"

Template.roundHistory.calcPoints = ->
  tre = Handlebars._default_helpers.tre()
  userId = Handlebars._default_helpers.currUserId()

  if tre.pointsRule is "ownAnswer"

    return "" unless this.bestAnsUserIds

    if this.bestAnsUserIds.indexOf(userId) >= 0
      pts = 100 / this.bestAnsUserIds.length
      pts = Math.floor(pts)
      return pts
    else
      return 10

  else if tre.pointsRule is "average"

    correctAnswer = Settings.findOne({_id: this.questionId}).answer
    pts = Template.roundHistory.getPoints(this.average, correctAnswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

Template.roundHistory.getPoints = (ans, correct) ->
  if Math.abs(ans - correct) > 50
    return 10
  else
    return 110 - 2 * Math.abs(ans - correct)
