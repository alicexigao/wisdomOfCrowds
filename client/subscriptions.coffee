Meteor.subscribe "settingsTaskQuestions"

Meteor.subscribe "settingsTutorialQuestions"

Meteor.subscribe "treatment"

Meteor.subscribe "chatMessages"

Meteor.subscribe "users"

Meteor.subscribe "timers"

#Meteor.subscribe "playerStatus", ->
#    PlayerStatus.find().observeChanges
#      changed: (id, fields) ->
#        if PlayerStatus.find({ready: true}).count() is Meteor.users.find().count()
#          Router.go("/task")

Meteor.subscribe "errorMessages"
