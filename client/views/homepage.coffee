Template.homepage.events =
  "click #goToTutorial": (ev) ->
    Meteor.Router.to('/tutorial')

Template.homepage.rendered = ->
  Session.set("page", "homepage")