Template.chatRoom.messages = ->
  ChatMessages.find()

Template.chatRoom.events =
  "submit form": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    chatData =
      author: Meteor.user().username
      timestamp: (new Date()).toUTCString()
      content: msgContent.val()

    if msgContent.val()
      Meteor.call 'sendMsg', chatData, (error, id) ->
        if error
          return alert(error.reason)

    msgContent.val ""
    msgContent.focus()

#    scroll to bottom
    $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.chatRoom.timestampFormat = ->
  (new Date(this.timestamp)).toLocaleTimeString()

Template.chatRoom.rendered = ->
  #    scroll to bottom
  $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.chatRoom.displayChatRoom = ->
  obj = Treatment.findOne()
  if obj
    return obj.displayChatRoom
