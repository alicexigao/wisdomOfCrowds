Handlebars.registerHelper "tre", ->
  return Treatment.findOne()

Handlebars.registerHelper "showBestAns", ->
  tre = Handlebars._default_helpers.tre()
  return tre.showBestAns


Handlebars.registerHelper "getRoundIndex", ->
  if Session.equals("page", "tutorial")
    return Session.get("tutorialRoundIndex")
  else
    return unless Settings.findOne({key: "roundIndex"})
    Settings.findOne({key: "roundIndex"}).value


Handlebars.registerHelper "getRoundObj", ->
  i = Handlebars._default_helpers.getRoundIndex()
  rounds = Handlebars._default_helpers.rounds()
  rounds.findOne({index: i})



Handlebars.registerHelper "users", ->
  if Session.equals("page", "tutorial")
    TutorialUsers.find({}, {sort: {rand: 1}})
  else
    Meteor.users.find({}, {sort: {rand: 1}})

Handlebars.registerHelper "currUser", ->
  if Session.equals("page", "tutorial")
    TutorialUsers.findOne({username: Meteor.user().username})
  else
    Meteor.user()

Handlebars.registerHelper "currUserId", ->
  if Session.equals("page", "tutorial")
    currUser = TutorialUsers.findOne({username: Meteor.user().username})
    currUser._id
  else
    Meteor.userId()

Handlebars.registerHelper "answers", ->
  if Session.equals("page", "tutorial")
    TutorialAnswers
  else
    Answers

Handlebars.registerHelper "ansObjForId", (id) ->
  index = Handlebars._default_helpers.getRoundIndex()
  ansColl = Handlebars._default_helpers.answers()
  if Session.equals("page", "tutorial")
    ansColl.findOne {userId: id}
  else
    ansColl.findOne {roundIndex: index, userId: id}

Handlebars.registerHelper "ansObjForIndexId", (index, id) ->
  ansColl = Handlebars._default_helpers.answers()
  if Session.equals("page", "tutorial")
    ansColl.findOne {userId: id}
  else
    ansColl.findOne {roundIndex: index, userId: id}

Handlebars.registerHelper "finalizedAns", ->
  index = Handlebars._default_helpers.getRoundIndex()
  ansColl = Handlebars._default_helpers.answers()
  if Session.equals("page", "tutorial")
    ansColl.find {status: "finalized"}
  else
    ansColl.find {roundIndex: index, status: "finalized"}

Handlebars.registerHelper "answersFinalized", ->
  usersCursor = Handlebars._default_helpers.users()
  finalizedAnsCursor = Handlebars._default_helpers.finalizedAns()
  return finalizedAnsCursor.count() is usersCursor.count()

Handlebars.registerHelper "rounds", ->
  if Session.equals("page", "tutorial")
    TutorialRounds
  else
    Rounds

Handlebars.registerHelper "clearBestAnsAndAvg", ->
  tutorialRoundIndex = Session.get("tutorialRoundIndex")
  TutorialRounds.update
    index: tutorialRoundIndex
  ,
    $set:
      average: undefined
  TutorialRounds.update
    index: tutorialRoundIndex
  ,
    $set:
      bestAns: undefined
  TutorialRounds.update
    index: tutorialRoundIndex
  ,
    $set:
      bestAnsUserIds: undefined


Handlebars.registerHelper "calcBestAnsAndAvg", ->
  tutorialRoundIndex = Session.get("tutorialRoundIndex")

  correct = TutorialRounds.findOne(
    index: tutorialRoundIndex
  ).correctanswer
  numAns = 0
  sumAns = 0
  bestAns = -Infinity

  for user in TutorialUsers.find().fetch()
    userId = user._id
    ans = TutorialAnswers.findOne(
      userId: userId
    ).answer
    sumAns += ans
    numAns++
    if Math.abs(ans - correct) < Math.abs(bestAns - correct)
      bestAns = ans

  bestAnsUserids = []
  for user in TutorialUsers.find().fetch()
    userId = user._id
    ans = TutorialAnswers.findOne(
      userId: userId
    ).answer
    if ans is bestAns
      bestAnsUserids.push userId

  avg = sumAns / numAns
  TutorialRounds.update {index: tutorialRoundIndex},
    $set: {average: avg}

  TutorialRounds.update {index: tutorialRoundIndex},
    $set: {bestAns: bestAns}
  TutorialRounds.update {index: tutorialRoundIndex},
    $set: {bestAnsUserIds: bestAnsUserids}

Handlebars.registerHelper "chat", ->
  if Session.equals("page", "tutorial")
    TutorialChat
  else
    ChatMessages

