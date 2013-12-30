if Meteor.isServer

  Meteor.publish "treatment", ->
    Treatment.find({value: "avgPublicChat"})

  Meteor.publish "users", ->
    Meteor.users.find {"status.online": true}
#      fields:
#        username: 1
#        rand: 1

  Meteor.publish "settingsTaskQuestions", ->
    Settings.find {key: "taskQuestion"},
      fields:
        key: 1
        value: 1

  Meteor.publish "settingsTutorialQuestions", ->
    Settings.find {key: "tutorialQuestion"},
      fields:
        key: 1
        value: 1

  Meteor.publish "correctAnswer", (id) ->
    Settings.find {_id: id},
      fields:
        answer: 1

  Meteor.publish "rounds", (page) ->
    Rounds.find {page: page},
      sort:
        index: 1

  # TODO: do not publish answers if they should not be revealed
  Meteor.publish "answers", (page) ->
    Answers.find {page: page}

  Meteor.publish "chatMessages", (page) ->
    ChatMessages.find {page: page}

  Meteor.publish "timers", ->
    Timers.find()

  Meteor.publish 'errorMessages', ->
    ErrorMessages.find()
