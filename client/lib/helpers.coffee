@Util = @Util || {}

Util.showBestAns = -> Treatment.findOne()?.showBestAns
Util.showAvg = -> Treatment.findOne()?.showAvg

Handlebars.registerHelper "showBestAns", Util.showBestAns
Handlebars.registerHelper "showAvg", Util.showAvg

# Get treatment
Util.tre = -> Treatment.findOne()

# Get current round index
Util.getRoundIndex = ->
  if Session.equals("page", "tutorial")
    return Session.get("tutorialRoundIndex")
  else
    TurkServer.currentRound()?.index - 1

# Get current round object
Util.getCurrRoundObj = ->
  index = Util.getRoundIndex()
  Rounds.findOne({index: index})

Util.getUserCursor = ->
  if Session.equals("page", "tutorial")
    TutorialUsers.find({}, {sort: {_id: 1}})
  else if Session.equals("page", "task")
    Meteor.users.find({"status.online": true}, {sort: {_id: 1}})

Handlebars.registerHelper "userCursor", Util.getUserCursor

Util.getCurrUserId = ->
  if Session.equals("page", "tutorial")
    currUser = null
    if Meteor.user().username
      currUser = TutorialUsers.findOne({username: Meteor.user().username})
    else
      currUser = TutorialUsers.findOne({username: Meteor.userId()})
    currUser._id
  else if Session.equals("page", "task")
    Meteor.userId()

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




Handlebars.registerHelper "clearBestAnsAndAvg", ->
  tutorialRoundIndex = Session.get("tutorialRoundIndex")
  TutorialRounds.update
    index: tutorialRoundIndex
  , $set:
      average: undefined
  TutorialRounds.update
    index: tutorialRoundIndex
  , $set:
      bestAns: undefined
  TutorialRounds.update
    index: tutorialRoundIndex
  ,
    $set:
      bestAnsUserIds: undefined

