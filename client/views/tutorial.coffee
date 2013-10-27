Template.tutorial.treatmentOne_steps = [
  template: Template.tutorial_step0
,
  template: Template.tutorial_step1a
  spot: ".currPlayerAnswer, .currPlayerInput"
#  onLoad: -> console.log "something for step 1"
,
  template: Template.tutorial_step1b
  spot: ".currPlayerInput"
,
  template: Template.tutorial_step2_1
  spot: ".otherPlayerAnswers"
,
  template: Template.tutorial_step3
  spot: ".timerDuringGame"
,
  template: Template.tutorial_step4_1
,
  template: Template.tutorial_step5_1
]

Template.tutorial.treatmentFour_steps = [
  template: Template.tutorial_step0
,
  template: Template.tutorial_step1a
  spot: ".currPlayerAnswer"
  onLoad: -> console.log "something for step 1"
,
  template: Template.tutorial_step2_4
  spot: ".divChatRoom"
,
  template: Template.tutorial_step3
  spot: ".timerDuringGame"
,
  template: Template.tutorial_step4_1
,
  template: Template.tutorial_step5_1
]

Template.tutorial.rendered = ->
  Session.set("page", "tutorial")

  return unless Timers.findOne({name: "first"})
  if Timers.findOne({name: "first"}).start is true
    Meteor.call "stopTimerFirst"


Template.tutorial_step0.events =
  "click .goToTask": (ev) ->
    Router.go("/task")
