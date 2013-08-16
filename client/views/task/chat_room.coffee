Template.chatRoom.messages = ->
  chatColl = Handlebars._default_helpers.chat()
  chatColl.find()

Template.chatRoom.events =
  "submit form": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    if msgContent.val()
      data =
        timestamp : new Date()
        content   : msgContent.val()

      if Session.equals("page", "tutorial")
        TutorialChat.insert
          userId    : Handlebars._default_helpers.currUserId()
          username  : Handlebars._default_helpers.currUser().username
          timestamp : data.timestamp
          content   : data.content
      else if Session.equals("page", "task")
        Meteor.call 'sendMsg', data, (err, res) ->
          return bootbox.alert err.reason if err

    msgContent.val ""
    # scroll to bottom
    $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))

Template.chatRoom.timestampFormat = ->
  (new Date(this.timestamp)).toLocaleTimeString()

Template.chatRoom.rendered = ->
  # scroll to bottom
  $('ul#messageArea').scrollTop($('ul#messageArea').prop("scrollHeight"))


