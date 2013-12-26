Handlebars.registerHelper "getTemplateAnswers", ->
  return unless Handlebars._default_helpers.subsReady()

  tre = Handlebars._default_helpers.tre()
  return unless tre

  if tre.showOtherAns is false and tre.showChatRoom is false
    return Template.tutorial_step_answers_private
  else if tre.showOtherAns is true and tre.showChatRoom is false
    return Template.tutorial_step_answers_public
  else if tre.showOtherAns is false and tre.showChatRoom is true
    return Template.tutorial_step_answers_privateChat
  else
    return Template.tutorial_step_answers_publicChat


Handlebars.registerHelper "getTemplateBreak", ->
  return unless Handlebars._default_helpers.subsReady()

  tre = Handlebars._default_helpers.tre()
  return unless tre

  if tre.showBestAns is true
    return Template.tutorial_step_break_best
  else if tre.showAvg is true
    return Template.tutorial_step_break_average


Handlebars.registerHelper "getTemplateRewardRule", ->
  return unless Handlebars._default_helpers.subsReady()

  tre = Handlebars._default_helpers.tre()
  return unless tre

  if tre.rewardRule is "best"
    return Template.tutorial_step_rewardrule_1
  else if tre.rewardRule is "average"
    return Template.tutorial_step_rewardrule_2


Deps.autorun ->

  Template.tutorial.tutorial_steps = {
    steps: [
      template: Template.tutorial_step_intro
      spot: ".task"
      onLoad: ->
        userIdBob = TutorialUsers.findOne({username: "Bob"})._id
        userIdCarol = TutorialUsers.findOne({username: "Carol"})._id

        Meteor.call "updateTutorialAnswer", {userId: userIdBob, status: "submitted"}
        Meteor.call "updateTutorialAnswer", {userId: userIdCarol, status: "finalized"}
    ,
      template: Template.tutorial_step_youranswer
      spot: ".currPlayerInput, .currPlayerAnswer"
    ,
      template: Handlebars._default_helpers.getTemplateAnswers()
      spot: ".currPlayerInput, .currPlayerAnswer, .otherPlayerAnswers, .divChatRoom"
    ,
      template: Template.tutorial_step_timelimit
      spot: ".roundQuestion, .timerDuringGame"
    ,
      template: Handlebars._default_helpers.getTemplateBreak()
      spot: ".timerDuringBreak, .correctAndAverageAns, .currPlayerAnswer, .otherPlayerAnswers"
      onLoad: ->
        userIdBob = TutorialUsers.findOne({username: "Bob"})._id
        userIdCarol = TutorialUsers.findOne({username: "Carol"})._id
        currUserId = Handlebars._default_helpers.currUserId()

        Meteor.call "updateTutorialAnswer", {userId: userIdBob, status: "finalized"}
        Meteor.call "updateTutorialAnswer", {userId: userIdCarol, status: "finalized"}
        Meteor.call "updateTutorialAnswer", {userId: currUserId, status: "finalized"}

        # Uncomment this and you will see that the tutorial reloads and displays the first step here.
#        Meteor.call "calcRoundAverage"
    ,
      template: Handlebars._default_helpers.getTemplateRewardRule()
    ]
    onFinish: ->
      Router.go("/lobby")
  }


Template.tutorial_step_youranswer.events =
  "click .clearAnswer": (ev) ->
    currUserId = Handlebars._default_helpers.currUserId()
    Meteor.call "clearTutorialCurrUserAnswer", currUserId

Template.tutorial.rendered = ->
  Session.set("page", "tutorial")

  return unless Timers.findOne({name: "first"})
  if Timers.findOne({name: "first"}).start is true
    Meteor.call "stopTimerFirst"
