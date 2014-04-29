Template.answers.treatmentDisplay = ->
  switch TurkServer.treatment()?.name
    when "bestPrivate", "bestPrivateChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgPrivateChat", "avgPublic", "avgPublicChat"
      return Template.ansOneStage
    else return null

Template.ansOneStage.isCurrentUser = ->
  currUserId = Util.getCurrUserId()
  return currUserId is @_id

Template.ansOneStage.showAnswer = ->
  if Util.answersFinalized()
    getAnsDurBreak(@_id)
  else
    getAnsDurRound(@_id)

# Get answer during the break
getAnsDurBreak = (userId) ->
  ansObj = Util.ansObjForId(userId)
  if ansObj is undefined
    console.log Meteor.userId()
    console.log userId
  return ansObj.answer + "%"

# Get answer during round
getAnsDurRound = (userId) ->
  ansObj = Util.ansObjForId(userId)
  return "pending" unless ansObj

  tre = TurkServer.treatment()
  currUserId = Util.getCurrUserId()
  if currUserId is userId
    # always display current user's answer
    return ansObj.answer + "%"
  else if tre.showOtherAns
    return ansObj.answer + "%"
  else
    return ansObj.status

Template.ansOneStage.showBestAnsLabel = ->
  return false unless Util.showBestAns()
  return false unless Util.answersFinalized()
  round = Util.getCurrRoundObj()
  if round.bestAnsUserIds
    return @_id in round.bestAnsUserIds
  return false

Template.correctAns.correctAnswer = ->
  questionId = Util.getCurrRoundObj().questionId
  Meteor.subscribe "correctAnswer", questionId
  Settings.findOne({_id: questionId}).answer

Template.averageAns.getAverageString = ->
  tre = TurkServer.treatment()
  switch tre.rewardRule
    when "average"
      return "average"

Template.averageAns.getAverage = ->
  round = Util.getCurrRoundObj()
  tre = TurkServer.treatment()
  if tre.rewardRule is "average"
    avg = round.average
  avg = parseInt(avg * 100) / 100
  return avg

Template.ansOneStage.username = ->
  if this.username
    this.username
  else
    this._id

