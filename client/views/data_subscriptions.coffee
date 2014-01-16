Deps.autorun ->
  TurkServer.group()
  Meteor.subscribe "treatment"

Meteor.subscribe "users"

Meteor.subscribe "chatMessages"

Meteor.subscribe "timers"

Meteor.subscribe "errorMessages"
