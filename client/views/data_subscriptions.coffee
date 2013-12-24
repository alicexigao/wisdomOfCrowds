handles = []
handles.push(Meteor.subscribe "treatment")

Meteor.subscribe "users"

Meteor.subscribe "settingsTaskQuestions"

Meteor.subscribe "settingsTutorialQuestions"

Meteor.subscribe "chatMessages"

Meteor.subscribe "timers"

Meteor.subscribe "errorMessages"

Handlebars.registerHelper "subsReady", ->
  isReady = handles.every (handle)->
      return handle.ready()
  return isReady
