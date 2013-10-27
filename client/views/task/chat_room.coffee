Template.chatRoom.messages = ->
  chatColl = Handlebars._default_helpers.chat()
  chatColl.find()

Template.chatRoom.events =
  "submit form": (ev) ->
    ev.preventDefault()

    msgContent = $("input#msgContent")

    if msgContent.val()
      data =
        page      : Session.get("page")
        timestamp : new Date()
        content   : msgContent.val()

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


