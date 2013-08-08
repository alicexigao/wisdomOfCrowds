Meteor.publish "treatment", ->
  Treatment.find()

Meteor.publish "currentRound", ->
  CurrentRound.find()

Meteor.publish "rounds", ->
  Rounds.find {},
    sort: {index: 1}

# TODO: do not publish answers if they should not be revealed
Meteor.publish "userInputs", ->
  [
    Answers.find(),
    Votes.find(),
    Bets.find()
  ]

Meteor.publish "chatMessages", ->
  ChatMessages.find()

Meteor.publish "usernames", ->
  Meteor.users.find {"profile.online": true},
    fields:
      username: 1
      rand: 1

Meteor.publish "timers", ->
  Timers.find()



Meteor.publish "tutorial", ->
  [
    TutorialCounter.find(),
    TutorialText.find(),
    TutorialData.find()
  ]

Meteor.publish "playerStatus", ->
  PlayerStatus.find()

Meteor.publish 'errorMessages', ->
  ErrorMessages.find()