Handlebars.registerHelper "readyToRender", ->
#  console.log "ready to render called"

  tre = Handlebars._default_helpers.tre()
#  console.log "treatment is " + tre
  return false unless tre

  currRound = Rounds.findOne({active: true})
#  console.log "currRound is #{JSON.stringify(currRound)}"
  return false unless currRound

  return true



# Get treatment
Handlebars.registerHelper "tre", ->
  return Treatment.findOne()

Handlebars.registerHelper "showBestAns", ->
  tre = Handlebars._default_helpers.tre()
  return tre.showBestAns




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
    return unless Rounds.findOne({active: true})
    Rounds.findOne({active: true}).index

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
    return TutorialUsers.find({}, {sort: {rand: 1}})
  else if Session.equals("page", "task")
    return Meteor.users.find({}, {sort: {rand: 1}})

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
  Answers

Handlebars.registerHelper "ansObjForId", (id) ->
  index = Handlebars._default_helpers.getRoundIndex()
  Answers.findOne({roundIndex: index, userId: id})

Handlebars.registerHelper "ansObjForIndexId", (index, id) ->
  Answers.findOne {roundIndex: index, userId: id}

Handlebars.registerHelper "finalizedAns", ->
  index = Handlebars._default_helpers.getRoundIndex()
  ansColl = Handlebars._default_helpers.answers()
  ansColl.find {roundIndex: index, status: "finalized"}

Handlebars.registerHelper "answersFinalized", ->
  usersCursor = Handlebars._default_helpers.users()
  return unless usersCursor
  finalizedAnsCursor = Handlebars._default_helpers.finalizedAns()
  return unless finalizedAnsCursor

  return finalizedAnsCursor.count() is usersCursor.count()


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
  ChatMessages

