Template.homepage.events =
  "click #goToTutorial": (ev) ->
    Router.go("/tutorial")

Template.homepage.rendered = ->
  Session.set("page", "homepage")