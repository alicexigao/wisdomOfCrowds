
Template.timerSecond.countdown = ->
  Meteor.call 'countdownSecond', null, (error, result) ->
    if error
      return bootbox.alert error.reason

if Template.timerSecond.intervalIdSecond is undefined
  Template.timerSecond.intervalIdSecond = Meteor.setInterval Template.timerSecond.countdown, 1000

Template.timerSecond.getTimeLeft = ->
  if Timers.findOne({name: "second"}) is undefined
    return
  numTotalSeconds = Timers.findOne({name: "second"}).secondsLeft
  if numTotalSeconds
    seconds = numTotalSeconds % 60
    minutes = (numTotalSeconds - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return "0:00"
