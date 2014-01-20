@Util = @Util || {}

Util.showBestAns = -> Treatment.findOne()?.showBestAns
Util.showAvg = -> Treatment.findOne()?.showAvg

Handlebars.registerHelper "hasActiveRound", ->
  Rounds.find({active: true}).count() > 0

# Get treatment
Handlebars.registerHelper "tre", ->
  return Treatment.findOne()

Handlebars.registerHelper "showBestAns", Util.showBestAns
Handlebars.registerHelper "showAvg", Util.showAvg

# Get rounds collection
Handlebars.registerHelper "rounds", ->
  Rounds

# Get number of rounds
Handlebars.registerHelper "numRounds", ->
  Rounds.find().count()

# Get current round index
Handlebars.registerHelper "getRoundIndex", ->
  if Session.equals("page", "tutorial")
    return Session.get("tutorialRoundIndex")
  else
#    return unless Rounds.findOne({active: true})
    Rounds.findOne({active: true})?.index

# Get current round object
Handlebars.registerHelper "getCurrRoundObj", ->
  Rounds.findOne({active: true})

Handlebars.registerHelper "userColl", ->
  if Session.equals("page", "tutorial")
    TutorialUsers
  else
    Meteor.users

Handlebars.registerHelper "users", ->
  if Session.equals("page", "tutorial")
    TutorialUsers.find({}, {sort: {_id: 1}})
  else if Session.equals("page", "task")
    Meteor.users.find({"status.online": true}, {sort: {_id: 1}})

Handlebars.registerHelper "currUser", ->
  if Session.equals("page", "task")
    Meteor.user()
  else if Session.equals("page", "tutorial")
    if Meteor.user().username
      TutorialUsers.findOne({username: Meteor.user().username})
    else
      TutorialUsers.findOne({username: Meteor.userId()})

Handlebars.registerHelper "currUserId", ->
  if Session.equals("page", "tutorial")
    currUser = null
    if Meteor.user().username
      currUser = TutorialUsers.findOne({username: Meteor.user().username})
    else
      currUser = TutorialUsers.findOne({username: Meteor.userId()})
    currUser._id
  else if Session.equals("page", "task")
    Meteor.userId()

Handlebars.registerHelper "answers", ->
  Answers

Handlebars.registerHelper "ansObjForId", (id) ->
  index = Handlebars._default_helpers.getRoundIndex()
  Answers.findOne({roundIndex: index, userId: id})

Handlebars.registerHelper "ansObjForIndexId", (index, id) ->
  Answers.findOne {roundIndex: index, userId: id}

Handlebars.registerHelper "answersFinalized", ->
  usersCursor = Handlebars._default_helpers.users()
  return false unless usersCursor
  for user in usersCursor.fetch()
    ansObj = Handlebars._default_helpers.ansObjForId(user._id)
    return false unless ansObj
    if ansObj.status isnt "finalized"
      return false
  return true

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

Handlebars.registerHelper "chat", ->
  ChatMessages

