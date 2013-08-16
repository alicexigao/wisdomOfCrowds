getIndex = ->
  return Session.get("tutorialIndex")

Template.tutorial.readyToRender = ->
  return false unless Tutorial.find()
  tre = Handlebars._default_helpers.tre()
  return false unless tre
  return true

Template.tutorial.rendered = ->

  Session.set("page", "tutorial")

  if not TutorialUsers.findOne({username: Meteor.user().username})
    TutorialUsers.insert
      username: Meteor.user().username
      rand: Math.random()

  return unless Timers.findOne({name: "first"})
  if Timers.findOne({name: "first"}).start is true
    Meteor.call "stopTimerFirst"

Template.tutorial.showInterface = ->
  return getIndex() isnt 0

Template.tutorial.showClearYourAnswerButton = ->
  return getIndex() in [1, 2, 3]

Template.tutorial.events =
  "click #goToQuiz": (ev) ->
    Meteor.Router.to("/quiz")

  "click #nextPage": (ev) ->
    index = Session.get("tutorialIndex")

    if index is 1
      addOtherAnswers()
    else if index is 3
      finalizeAllAnswers()

    Session.set("tutorialIndex", index + 1)

  "click #previousPage": (ev) ->
    index = Session.get("tutorialIndex")

    if index is 2
      clearOtherAnswers()
    else if index is 4
      undoFinalizeAllAnswers()

    Session.set("tutorialIndex", index - 1)

  "click #clearYourAnswer": (ev) ->
    currUserId = Handlebars._default_helpers.currUserId()
    TutorialAnswers.remove({userId: currUserId})

finalizeAllAnswers = ->
  users = Handlebars._default_helpers.users()
  for user in users.fetch()
    if TutorialAnswers.findOne({userId: user._id})
      TutorialAnswers.update {userId: user._id},
        $set:
          status: "finalized"
    else
      TutorialAnswers.insert
        userId: user._id
        answer: 50
        status: "finalized"

  Handlebars._default_helpers.calcBestAnsAndAvg()

undoFinalizeAllAnswers = ->
  Handlebars._default_helpers.clearBestAnsAndAvg()
  clearOtherAnswers()
  addOtherAnswers()

addOtherAnswers = ->
  userId = TutorialUsers.findOne({username: "Bob"})._id
  if not TutorialAnswers.findOne({userId: userId})
    TutorialAnswers.insert
      userId: userId
      answer: 37
      status: "submitted"

  userId = TutorialUsers.findOne({username: "Carol"})._id
  if not TutorialAnswers.findOne({userId: userId})
    TutorialAnswers.insert
      userId: userId
      answer: 80
      status: "finalized"

clearOtherAnswers = ->
  userId = TutorialUsers.findOne({username: "Bob"})._id
  TutorialAnswers.remove
    userId: userId
  userId = TutorialUsers.findOne({username: "Carol"})._id
  TutorialAnswers.remove
    userId: userId


Template.tutorial.getText = ->
  index = getIndex()
  texts = Tutorial.find({key: "text", index: index}).fetch()
  if texts.length is 1
    return texts[0].value
  else
    tre = Handlebars._default_helpers.tre()
    if index is 2
      return Tutorial.findOne(
        key: "text"
        index: index
        showOtherAns: tre.showOtherAns
        showChatRoom: tre.showChatRoom
      ).value
    if index is 4 or index is 5
      return Tutorial.findOne(
        key: "text"
        index: index
        showBestAns: tre.showBestAns
        showAvg: tre.showAvg
      ).value

Template.tutorial.lastStep = ->
  numPages = Tutorial.findOne({key: "numPages"}).value
  return getIndex() is numPages - 1

Template.tutorial.disablePrevious = ->
  index = getIndex()
  if index is 0
    return "disabled"
  return ""

Template.tutorial.disableNext = ->
  if Template.tutorial.lastStep()
    return "disabled"
  return ""

Template.tutorial.getPageNum = ->
  return getIndex() + 1

Template.tutorial.getTotalPageNum = ->
  return Tutorial.findOne({key: "numPages"}).value



