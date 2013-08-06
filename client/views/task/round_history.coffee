Template.roundHistory.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.roundHistory.isRoundFinished = (round) ->
  return round.status is "completed"

Template.roundHistory.roundFinished = ->
  return this.status is "completed"

Template.roundHistory.getIndex = ->
  if Template.roundHistory.isRoundFinished(this)
    return this.index + 1
  return ""

Template.roundHistory.getMyAnswerString = ->
  if Template.roundHistory.isRoundFinished(this)

    uid = Meteor.user()._id
    str = this.answers[uid].answer + "%"

    tre = Treatment.findOne()
    if tre and tre.displaySecondStage is true and Treatment.findOne().secondStageType is "voting"
      numVotes = Template.roundHistory.getNumVotes(this, uid)
      str += "(#{numVotes})"

    return str
  return ""

Template.roundHistory.getNumVotes = (round, userId) ->
  numVotes = 0
  for uid in Object.keys(round.votes)
    if round.votes[uid].vote is userId
      numVotes++
  return numVotes

Template.roundHistory.getOtherAnswersString = ->
  if Template.roundHistory.isRoundFinished(this)
    str = ""
    for userId in Object.keys(this.answers)
      if userId is Meteor.user()._id
        continue
      str += "#{this.answers[userId].answer}%"

      tre = Treatment.findOne()
      if tre and tre.displaySecondStage is true and tre.secondStageType is "voting"
        numVotes = Template.roundHistory.getNumVotes(this, userId)
        str += "(#{numVotes}),"
      else
        str += ","
    return str.substring(0, str.length - 1)
  return ""

Template.roundHistory.displayWinner = ->
  return Template.roundAnswers.displayWinner()

Template.roundHistory.getWinningAnswerString = ->
  if Template.roundHistory.isRoundFinished(this)
    correctAnswer = this.correctanswer
    bestAnswer = -Infinity
    for userId in Object.keys(this.answers)
      ans = this.answers[userId].answer
      if Math.abs(ans - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
        bestAnswer = ans
    return bestAnswer + "%"
  return ""



Template.roundHistory.getCorrectAnswer = ->
  str = ""
  if Template.roundHistory.isRoundFinished(this)
    str += this.correctanswer + "%"
    return str
  return ""


Template.roundHistory.calcPoints = ->
  tre = Treatment.findOne()

  if tre and tre.pointsRule is "ownAnswer"
    # points based on individual answer
    if Template.roundHistory.isRoundFinished(this)
      uid = Meteor.user()._id
      len = this.winnerIdArray.length
      if uid in this.winnerIdArray
        pts = 100 / len
        pts = Math.round(pts)
        return pts
      else
        return 10

  else if tre and tre.pointsRule is "ownAnswerByVotes"
    uid = Meteor.user()._id
    len = this.winnerIdArray.length
    vote = this.votes[uid].vote
    if vote in this.winnerIdArray
      pts = 100 / len
      pts = Math.round(pts)
      return pts
    else
      return 10

  else if tre and tre.pointsRule is "ownAnswerByBets"
    uid = Meteor.user()._id
    bets = this.bets[uid]
    total = 0
    odds = 10
    for answerUID in Object.keys(bets)
      if answerUID in this.winnerIdArray
        total += bets[answerUID].amount * odds
    if total is 0
      return 10
    return total

  else if tre and tre.pointsRule is "average"
    # points based on simple average
    pts = Template.roundHistory.getPoints(this.average, this.correctanswer)
    pts = parseInt(pts * 100) / 100
    return pts

  else if tre and tre.pointsRule is "averageByVotes"
    # points based on weighted average
    pts = Template.roundHistory.getPoints(this.averageByVotes, this.correctanswer)
    pts = parseInt(pts * 100) / 100
    return pts

  else if tre and tre.pointsRule is "averageByBets"
    pts = Template.roundHistory.getPoints(this.averageByBets, this.correctanswer)
    pts = parseInt(pts * 100) / 100
    return pts

Template.roundHistory.getPoints = (ans, correct) ->
  if Math.abs(ans - correct) > 50
    return 10
  else
    return 110 - 2 * Math.abs(ans - correct)





Template.roundHistory.displayAverage = ->
  tre = Treatment.findOne()
  return unless tre
  return tre.displayAverage

Template.roundHistory.getAverageHeader = ->
  tre = Treatment.findOne()
  return unless tre
  if tre.pointsRule is "average"
    return "Average"
  else if tre.pointsRule is "averageByVotes"
    return "Average (by votes)"
  else if tre.pointsRule is "averageByBets"
    return "Average (by bets)"

Template.roundHistory.getAverageString = ->
  return "" unless Template.roundHistory.isRoundFinished(this)

  tre = Treatment.findOne()
  return "" unless tre

  if tre.pointsRule is "average"
    avg = this.average
  else if tre.pointsRule is "averageByVotes"
    avg = this.averageByVotes
  else if tre.pointsRule is "averageByBets"
    avg = this.averageByBets

  avg = parseInt(avg * 100) / 100
  return avg + "%"
