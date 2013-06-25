Meteor.publish "chatMessages", ->
  ChatMessages.find()

Meteor.publish "answers", ->
  Answers.find()

Meteor.publish "rounds", ->
  Rounds.find()

Meteor.publish "currentRound", ->
  CurrentRound.find()

Meteor.publish "usernames", ->
  Meteor.users.find {'profile.online': true},
    fields:
      username: 1