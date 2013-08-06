Meteor.publish "treatment", ->
  Treatment.find()

Meteor.publish "currentRound", ->
  CurrentRound.find()

Meteor.publish "rounds", ->
  Rounds.find {},
    sort: {index: 1}

Meteor.publish "answers", ->
  Answers.find {},
    fields:
      userId: 1
      answer: 1
      status: 1

Meteor.publish "chatMessages", ->
  ChatMessages.find()

Meteor.publish "usernames", ->
  Meteor.users.find {"profile.online": true},
    fields:
      username: 1
      rand: 1

Meteor.publish "timeleft", ->
  Timers.find()

Meteor.publish "votes", ->
  Votes.find()

Meteor.publish "bets", ->
  Bets.find()

Meteor.publish "tutorialCounter", ->
  TutorialCounter.find()

Meteor.publish "tutorialText", ->
  TutorialText.find()

Meteor.publish "tutorialData", ->
  TutorialData.find()

Meteor.publish "playerStatus", ->
  PlayerStatus.find()

Meteor.publish 'errorMessages', ->
  ErrorMessages.find()