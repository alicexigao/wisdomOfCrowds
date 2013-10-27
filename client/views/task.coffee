Template.task.rendered = ->
  Session.set("page", "task") unless Session.equals("page", "tutorial")

Template.task.showChatRoom = ->
  tre = Handlebars._default_helpers.tre()
  return tre.showChatRoom