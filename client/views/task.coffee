Template.task.readyToRender = ->
  return false unless Handlebars._default_helpers.tre()
  return true

Template.task.rendered = ->

  Session.set("page", "task") unless Session.equals("page", "tutorial")

  return unless Timers.findOne({name: "first"})

  if Session.equals("page", "tutorial")
    if Timers.findOne({name: "first"}).start is true
      Meteor.call "stopTimerFirst"
  else if Session.equals("page", "task")
    if Timers.findOne({name: "first"}).start is false
      Meteor.call "startTimerFirst"

Template.task.showChatRoom = ->
  tre = Handlebars._default_helpers.tre()
  return tre.showChatRoom