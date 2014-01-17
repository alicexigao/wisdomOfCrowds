Template.task.rendered = ->
  Session.set("page", "task") unless Session.equals("page", "tutorial")

Template.task.showChatRoom = -> Treatment.findOne()?.showChatRoom