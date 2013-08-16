Meteor.subscribe "settings"

Meteor.subscribe "treatment"

Meteor.subscribe "chatMessages"

Meteor.subscribe "rounds"

Meteor.subscribe "users"

Meteor.subscribe "timers"

Meteor.subscribe "tutorial"

Meteor.subscribe "playerStatus", ->
    PlayerStatus.find().observeChanges
      changed: (id, fields) ->
        if PlayerStatus.find({ready: true}).count() is Meteor.users.find().count()
          Meteor.Router.to('/task')

Meteor.subscribe "errorMessages"

Meteor.subscribe "userInputs"