
Template.timerMain.countdown = ->
  Meteor.call 'countdownMain', null, (error, id) ->
    if error
      return bootbox.alert error.reason

if Template.timerMain.intervalIdMain is undefined
  Template.timerMain.intervalIdMain = Meteor.setInterval Template.timerMain.countdown, 1000

Template.timerMain.getTimeLeft = ->
  if Timers.findOne({name: "main"}) is undefined
    return
  numTotalSeconds = Timers.findOne({name: "main"}).secondsLeft
  if numTotalSeconds
    seconds = numTotalSeconds % 60
    minutes = (numTotalSeconds - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return "0:00"
