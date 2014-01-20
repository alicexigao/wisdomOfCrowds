Handlebars.registerHelper "getTemplateAnswers", ->
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
  tre = Handlebars._default_helpers.tre()
  return unless tre

  if tre.showBestAns is true
    return Template.tutorial_step_break_best
  else if tre.showAvg is true
    return Template.tutorial_step_break_average

Handlebars.registerHelper "getTemplateRewardRule", ->
  tre = Handlebars._default_helpers.tre()
  return unless tre

  if tre.rewardRule is "best"
    return Template.tutorial_step_rewardrule_1
  else if tre.rewardRule is "average"
    return Template.tutorial_step_rewardrule_2

setTutorialAnswer = (username, status, createAnswer) ->
  userId = null
  if username
    userId = TutorialUsers.findOne({username: username})._id
  else
    userId = Handlebars._default_helpers.currUserId()
  Meteor.call "updateTutorialAnswer", {userId: userId, status: status, createAnswer: createAnswer}

tutorialSteps = [
    template: Template.tutorial_step_intro
    spot: ".task"
    onLoad: ->
      setTutorialAnswer(null, "submitted", false)
      setTutorialAnswer("Bob", "submitted", true)
      setTutorialAnswer("Carol", "finalized", true)
  ,
    template: Template.tutorial_step_youranswer
    spot: ".currPlayerInput, .currPlayerAnswer"
  ,
    template: Handlebars._default_helpers.getTemplateAnswers()
    spot: ".currPlayerInput, .currPlayerAnswer, .otherPlayerAnswers, .divChatRoom"
  ,
    template: Template.tutorial_step_timelimit
    spot: ".roundQuestion, .timerDuringGame"
    onLoad: ->
      setTutorialAnswer(null, "submitted", false)
      setTutorialAnswer("Bob", "submitted", false)
      setTutorialAnswer("Carol", "finalized", false)
  ,
    template: Handlebars._default_helpers.getTemplateBreak()
    spot: ".timerDuringBreak, .correctAndAverageAns, .currPlayerAnswer, .otherPlayerAnswers, .gameHistory"
    onLoad: ->
      setTutorialAnswer("Bob", "finalized", false)
      setTutorialAnswer("Carol", "finalized", false)
      setTutorialAnswer(null, "finalized", true)
      Meteor.call "calcAvgAndBest", TutorialUsers.find().fetch()
  ,
    template: Handlebars._default_helpers.getTemplateRewardRule()
    spot: ".gameHistory"
  ,
    template: Template.tutorial_step_bonusrule
    spot: ".gameHistory"
    onLoad: ->
      # TODO:  insert data for all rounds
]


Deps.autorun ->
  Template.tutorial.tutorial_steps =
    steps: tutorialSteps
    onFinish: ->
      Router.go("/quiz")

Template.tutorial_step_youranswer.events =
  "click .clearAnswer": (ev) ->
    setTutorialAnswer(null, "submitted", false)

Template.tutorial.rendered = ->
  Session.set("page", "tutorial")
