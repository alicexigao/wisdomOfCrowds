Meteor.subscribe "treatment"

Meteor.subscribe "chatMessages"

Meteor.subscribe "answers"

Meteor.subscribe "rounds"

Meteor.subscribe "currentRound"

Meteor.subscribe "usernames"

Meteor.subscribe "timeleft"

Meteor.subscribe "votes"

Meteor.subscribe "bets"

Meteor.subscribe "tutorialCounter"

Meteor.subscribe "tutorialText"

Meteor.subscribe "tutorialData"

Meteor.subscribe "playerStatus", ->
    PlayerStatus.find().observeChanges
      changed: (id, fields) ->
        if PlayerStatus.find({ready: true}).count() is Meteor.users.find().count()
          Meteor.Router.to('/task')

Meteor.subscribe "errorMessages"