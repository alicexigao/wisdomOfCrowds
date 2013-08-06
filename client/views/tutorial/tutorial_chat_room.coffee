Template.tutorialChatRoom.messages = ->
  ChatMessages.find()

Template.tutorialChatRoom.events =
  "submit form": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    chatData =
      author: Meteor.user().username
      timestamp: (new Date()).toUTCString()
      content: msgContent.val()

    if msgContent.val()
      Meteor.call 'sendMsg', chatData, (error, result) ->
        if error
          return alert(error.reason)

    msgContent.val ""
    msgContent.focus()

    # scroll to bottom
    $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.tutorialChatRoom.timestampFormat = ->
  (new Date(this.timestamp)).toLocaleTimeString()

Template.tutorialChatRoom.rendered = ->
  # scroll to bottom
  $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.tutorialChatRoom.displayChatRoom = ->
  obj = Treatment.findOne()
  if obj
    return obj.displayChatRoom
