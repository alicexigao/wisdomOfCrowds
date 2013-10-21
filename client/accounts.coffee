login = ->
  return if Meteor.userId()
  console.log "trying login"
  bootbox.prompt "Please enter a username", (username) ->
    Meteor.insecureUserLogin(username) if username?

# Start initial login after stuff loaded
Meteor.startup ->
  Meteor.setTimeout login, 50

  # TODO make sure this works inside MTurk iFrame
  # See http://stackoverflow.com/questions/6883827/detecting-active-window-in-an-iframe
#  blurDialog = null
#  $(window).bind "blur", ->
#    return if blurDialog
#    blurDialog = bootbox.alert "You are not supposed to do that! Please do not look up answers online.",
#      -> blurDialog = null

# Always request username if logged out
Deps.autorun(login)

