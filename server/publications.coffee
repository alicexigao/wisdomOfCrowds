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
  Meteor.users.find {'profile.online': true},
    fields:
      username: 1

Meteor.publish "timeleft", ->
  Timers.find()

Meteor.publish "votes", ->
  Votes.find()