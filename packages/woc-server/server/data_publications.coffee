
Meteor.publish "treatment", (name) ->
  Treatment.find( value: name )

Meteor.publish "users", ->
  Meteor.users.find()

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

Meteor.publish "rounds", ->
  Rounds.find {},
    sort:
      index: 1

# TODO: do not publish answers if they should not be revealed
Meteor.publish "answers", () ->
  Answers.find {}

Meteor.publish "chatMessages", () ->
  ChatMessages.find {}

Meteor.publish 'errorMessages', ->
  ErrorMessages.find()
