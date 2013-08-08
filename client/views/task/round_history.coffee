Template.roundHistory.readyToRender = ->
  tre = Treatment.findOne()
  return false unless tre
  return true

Template.roundHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.roundHistory.isRoundFinished = (round) ->
  return round.status is "completed"

Template.roundHistory.getIndexDisplay = ->
  return this.index + 1

Template.roundHistory.getMyAnswerString = ->
  answer = Answers.findOne({roundIndex: this.index, userId: Meteor.userId()}).answer
  str = answer + "%"

  tre = Handlebars._default_helpers.tre()
  if tre.showSecondStage and tre.secondStageType is "voting"
    numVotes = Template.roundHistory.getNumVotes()
    str += "(#{numVotes})"
  return str

Template.roundHistory.getNumVotes = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  numVotes = Votes.find({roundIndex: roundIndex, answerId: Meteor.userId()}).count()
  return numVotes

#Template.roundHistory.getOtherAnswersString = ->
#  str = ""
#  for userId in Object.keys(this.answers)
#    if userId is Meteor.userId()
#      continue
#    str += "#{this.answers[userId].answer}%"
#
#    tre = Treatment.findOne()
#    if tre.showSecondStage and tre.secondStageType is "voting"
#      numVotes = Template.roundHistory.getNumVotes()
#      str += "(#{numVotes}),"
#    else
#      str += ","
#  return str.substring(0, str.length - 1)

Template.roundHistory.showBestAns = ->
  tre = Handlebars._default_helpers.tre()
  return tre.showBestAns

Template.roundHistory.getWinningAnswerString = ->
  correctAnswer = this.correctanswer
  bestAnswer = -Infinity
  Answers.find({roundIndex: this.index}).forEach (record) ->
    ans = record.answer
    if Math.abs(ans - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
      bestAnswer = ans
  return bestAnswer + "%"

Template.roundHistory.getCorrectAnswer = ->
  return this.correctanswer + "%"

Template.roundHistory.calcPoints = ->
  tre = Handlebars._default_helpers.tre()

  if tre.pointsRule is "ownAnswer"
    if Template.roundHistory.isRoundFinished(this)
      userId = Meteor.userId()
      len = this.winnerIdArray.length
      if userId in this.winnerIdArray
        pts = 100 / len
        pts = Math.floor(pts)
        return pts
      else
        return 10

  else if tre.pointsRule is "ownAnswerByVotes"
    userId = Meteor.userId()
    len = this.winnerIdArray.length
    vote = Votes.find({roundIndex: this.index, userId: userId}).answerId
    if vote in this.winnerIdArray
      pts = 100 / len
      pts = Math.floor(pts)
      return pts
    else
      return 10

  else if tre.pointsRule is "ownAnswerByBets"
    # TODO: needs to update this
    userId = Meteor.userId()
    bets = this.bets[userId]
    total = 0
    odds = 10
    for answerUID in Object.keys(bets)
      if answerUID in this.winnerIdArray
        total += bets[answerUID].amount * odds
    if total is 0
      return 10
    return total

  else if tre.pointsRule is "average"
    pts = Template.roundHistory.getPoints(this.average, this.correctanswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

  else if tre.pointsRule is "averageByVotes"
    pts = Template.roundHistory.getPoints(this.averageByVotes, this.correctanswer)
    pts = parseInt(pts * 100, 10) / 100
    return pts

  else if tre.pointsRule is "averageByBets"
    pts = Template.roundHistory.getPoints(this.averageByBets, this.correctanswer)
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
  else if tre.pointsRule is "averageByVotes"
    return "Average (by votes)"
  else if tre.pointsRule is "averageByBets"
    return "Average (by bets)"

Template.roundHistory.getAverageString = ->
  tre = Handlebars._default_helpers.tre()
  if tre.pointsRule is "average"
    avg = this.average
  else if tre.pointsRule is "averageByVotes"
    avg = this.averageByVotes
  else if tre.pointsRule is "averageByBets"
    avg = this.averageByBets

  avg = parseInt(avg * 100, 10) / 100
  return avg + "%"
