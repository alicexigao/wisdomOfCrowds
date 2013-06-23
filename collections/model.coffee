this.ChatMessages = new Meteor.Collection('chatMessages')

ChatMessages.allow insert: (userId, doc) ->
    !! userId