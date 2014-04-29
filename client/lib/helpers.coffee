@Util = @Util || {}

Util.showBestAns = ->
  Treatment.findOne()?.showBestAns
Util.showAvg = ->
  Treatment.findOne()?.showAvg

Handlebars.registerHelper "showBestAns", Util.showBestAns
Handlebars.registerHelper "showAvg", Util.showAvg

# Get treatment
Util.tre = ->
  Treatment.findOne()

# Get current round index
Util.getRoundIndex = ->
  TurkServer.currentRound()?.index - 1

# Get current round object
Util.getCurrRoundObj = ->
  index = Util.getRoundIndex()
  Rounds.findOne({index: index})

Util.getUserCursor = ->
  return Meteor.users.find({}, {sort: {_id: 1}})

Handlebars.registerHelper "userCursor", Util.getUserCursor

Util.getCurrUserId = ->
  return Meteor.userId()

Util.ansObjForId = (id) ->
  index = Util.getRoundIndex()
  Answers.findOne({roundIndex: index, userId: id})

Util.answersFinalized = ->
  usersCursor = Util.getUserCursor()
  return false unless usersCursor
  for user in usersCursor.fetch()
    ansObj = Util.ansObjForId(user._id)
    return false unless ansObj
    if ansObj.status isnt "finalized"
      return false
  return true

Handlebars.registerHelper "answersFinalized", Util.answersFinalized

