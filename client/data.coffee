# fake users are the same, real user is the client
this.TutorialUsers = new Meteor.Collection(null)

Meteor.startup ->
  Session.set("tutorialRoundIndex", 0)

  TutorialUsers.remove({})
  TutorialUsers.insert
    username: "Bob"
    rand: Math.random()
  TutorialUsers.insert
    username: "Carol"
    rand: Math.random()

Deps.autorun ->
  # need to put this in this kind of block because
  # Meteor.startup gets called before the current user is loaded
  if Meteor.user()
    if Meteor.user().username
      if not TutorialUsers.findOne({username: Meteor.user().username})
        TutorialUsers.insert
          username: Meteor.user().username
          rand: Math.random()
    else
      if not TutorialUsers.findOne({username: Meteor.userId()})
        TutorialUsers.insert
          username: Meteor.userId()
          rand: Math.random()