Template.chatRoom.messages = ->
  ChatMessages.find()

Template.chatRoom.events =
  "click #sendMessage": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")
    if msgContent.val()
      ChatMessages.insert
        author: "Alice Gao"
        content: msgContent.val()

    msgContent.val ""
    msgContent.focus()