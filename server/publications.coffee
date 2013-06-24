Meteor.publish "chatMessages", ->
  ChatMessages.find()

Meteor.publish "answers", ->
  Answers.find()

Meteor.publish "usernames", ->
  Meteor.users.find {'profile.online': true},
    fields:
      username: 1

getOnlineUsers = ->
  Meteor.users.find {'profile.online': true},
    fields:
      username: 1