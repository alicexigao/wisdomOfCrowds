
Template.answers.treatmentDisplay = (treatment, context) ->
  switch treatment
    when "bestPrivate", "bestChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgChat", "avgPublic", "avgPublicChat"
      return new Handlebars.SafeString Template.ansOneStage(context)

Handlebars.registerHelper "isCurrentUser", ->
  currUserId = Handlebars._default_helpers.currUserId()
  return currUserId is @_id

Handlebars.registerHelper "showAnswer", ->
  if Handlebars._default_helpers.answersFinalized()
    return Handlebars._default_helpers.getAnsDurBreak(@_id)
  else
    return Handlebars._default_helpers.getAnsDurRound(@_id)

# get answer during the break between rounds
Handlebars.registerHelper "getAnsDurBreak", (userId) ->
  ansObj = Handlebars._default_helpers.ansObjForId(userId)
  if ansObj is undefined
    console.log Meteor.userId()
    console.log userId
  return ansObj.answer + "%"

# get answer during round
Handlebars.registerHelper "getAnsDurRound", (userId) ->
  ansObj = Handlebars._default_helpers.ansObjForId(userId)
  return "pending" unless ansObj

  tre = Handlebars._default_helpers.tre()
  currUserId = Handlebars._default_helpers.currUserId()
  if currUserId is userId
    # always display current user's answer
    return ansObj.answer + "%"
  else if tre.showOtherAns
    return ansObj.answer + "%"
  else
    return ansObj.status




Handlebars.registerHelper "showBestAnsLabel", ->
  return false unless Handlebars._default_helpers.tre().showBestAns
  return false unless Handlebars._default_helpers.answersFinalized()
  round = Handlebars._default_helpers.getCurrRoundObj()
  if round.bestAnsUserIds
    return @_id in round.bestAnsUserIds
  return false

Template.correctAns.correctAnswer = ->
  questionId = Handlebars._default_helpers.getCurrRoundObj().questionId
  Meteor.subscribe "correctAnswer", questionId
  return Settings.findOne({_id: questionId}).answer

Template.averageAns.getAverageString = ->
  tre = Handlebars._default_helpers.tre()
  switch tre.pointsRule
      when "average"
        return "average"

Template.averageAns.getAverage = ->
  round = Handlebars._default_helpers.getCurrRoundObj()
  tre = Handlebars._default_helpers.tre()
  if tre.pointsRule is "average"
    avg = round.average
  avg = parseInt(avg * 100) / 100
  return avg

Handlebars.registerHelper "showAvgAns", ->
  tre = Handlebars._default_helpers.tre()
  return false unless tre.showAvg
  return Handlebars._default_helpers.answersFinalized()


