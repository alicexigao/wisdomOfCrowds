Template.chatRoom.messages = ->
  ChatMessages.find()

Template.chatRoom.events =
  "click #sendMessage": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    if msgContent.val()
      ChatMessages.insert
        author: "Alice Gao"
        timestamp: (new Date()).toUTCString()
        content: msgContent.val()

    msgContent.val ""
    msgContent.focus()

Template.chatRoom.timestampFormat = ->
  (new Date(this.timestamp)).toLocaleTimeString()