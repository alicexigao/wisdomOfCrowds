Meteor.publish "chatMessages", ->
  ChatMessages.find()