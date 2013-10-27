Template.roundHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.roundHistory.isRoundFinished = (round) ->
  return round.status is "completed"

Template.roundHistory.getIndexDisplay = ->
  return this.index + 1

Template.roundHistory.getMyAnswerString = ->
  currUserId = Handlebars._default_helpers.currUserId()
  ansObj = Handlebars._default_helpers.ansObjForIndexId(@index, currUserId)
  return unless ansObj
  return ansObj.answer + "%"

Template.roundHistory.getWinningAnswerString = ->
  correctAnswer = this.correctanswer
  bestAnswer = -Infinity
  ansColl = Handlebars._default_helpers.answers()
  ansColl.find({roundIndex: this.index}).forEach (record) ->
    ans = record.answer
    if Math.abs(ans - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
      bestAnswer = ans
  return bestAnswer + "%"

Template.roundHistory.getCorrectAnswer = ->
  return this.correctanswer + "%"

Template.roundHistory.calcPoints = ->
  tre = Handlebars._default_helpers.tre()

  userId = Handlebars._default_helpers.currUserId()
  if tre.pointsRule is "ownAnswer"
    if Template.roundHistory.isRoundFinished(this)
      len = this.bestAnsUserIds.length
      if userId in this.bestAnsUserIds
        pts = 100 / len
        pts = Math.floor(pts)
        return pts
      else
        return 10

  else if tre.pointsRule is "average"
    pts = Template.roundHistory.getPoints(this.average, this.correctanswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

Template.roundHistory.getPoints = (ans, correct) ->
  if Math.abs(ans - correct) > 50
    return 10
  else
    return 110 - 2 * Math.abs(ans - correct)

Template.roundHistory.showAvg = ->
  tre = Handlebars._default_helpers.tre()
  tre.showAvg

Template.roundHistory.getAverageHeader = ->
  tre = Handlebars._default_helpers.tre()
  if tre.pointsRule is "average"
    return "Average"

Template.roundHistory.getAverageString = ->
  tre = Handlebars._default_helpers.tre()
  if tre.pointsRule is "average"
    avg = this.average
  avg = parseInt(avg * 100, 10) / 100
  return avg + "%"
