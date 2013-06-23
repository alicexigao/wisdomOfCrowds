Template.chatRoom.messages = ->
  ChatMessages.find()

Template.chatRoom.events =
  "submit form": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    if msgContent.val()
      ChatMessages.insert
        author: Meteor.user().username
        timestamp: (new Date()).toUTCString()
        content: msgContent.val()

    msgContent.val ""
    msgContent.focus()

#    scroll to bottom
    $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.chatRoom.timestampFormat = ->
  (new Date(this.timestamp)).toLocaleTimeString()