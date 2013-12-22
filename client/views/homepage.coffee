Template.homepage.events =
  "click #goToTutorial": (ev) ->
    Router.go("/task")

Template.homepage.rendered = ->
  Session.set("page", "homepage")