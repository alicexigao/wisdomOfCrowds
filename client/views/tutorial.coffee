Handlebars.registerHelper "getTemplateAnswers", ->
  return unless Handlebars._default_helpers.subsReady()

  tre = Handlebars._default_helpers.tre()
  return unless tre
  if tre.showOtherAns is false and tre.showChatRoom is false
    return Template.tutorial_step_answers_1
  else if tre.showOtherAns is true and tre.showChatRoom is false
    return Template.tutorial_step_answers_2
  else if tre.showOtherAns is false and tre.showChatRoom is true
    return Template.tutorial_step_answers_3
  else
    return Template.tutorial_step_answers_4


Deps.autorun ->
  Template.tutorial.treatmentOne_steps = {
    steps: [
      template: Template.tutorial_step_intro
      spot: ".task"
    ,
      template: Template.tutorial_step_youranswer
      spot: ".currPlayerAnswer, .currPlayerInput"
    ,
      template: Handlebars._default_helpers.getTemplateAnswers()
      spot: ".currPlayerAnswer, .otherPlayerAnswers"
    ,
      template: Template.tutorial_step_timelimit
      spot: ".timerDuringGame"
    ,
      template: Template.tutorial_step4_break_1
    ,
      template: Template.tutorial_step5_rewardrule_1
    ]
  }


Template.tutorial.rendered = ->
  Session.set("page", "tutorial")

  return unless Timers.findOne({name: "first"})
  if Timers.findOne({name: "first"}).start is true
    Meteor.call "stopTimerFirst"
