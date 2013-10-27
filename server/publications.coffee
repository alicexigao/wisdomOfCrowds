Meteor.publish "settings", ->
  Settings.find()

Meteor.publish "treatment", ->
  Treatment.find({value: "avgPublicChat"})

Meteor.publish "users", ->
  Meteor.users.find {"profile.online": true},
    fields:
      username: 1
      rand: 1

Meteor.publish "rounds", (page) ->
  Rounds.find {page: page},
    sort:
      index: 1

Meteor.publish "chatMessages", (page) ->
  ChatMessages.find {page: page}

# TODO: do not publish answers if they should not be revealed
Meteor.publish "answers", (page) ->
  Answers.find {page: page}

Meteor.publish "timers", ->
  Timers.find()

#Meteor.publish "playerStatus", ->
#  PlayerStatus.find()

Meteor.publish 'errorMessages', ->
  ErrorMessages.find()