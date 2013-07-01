#clock = 30

Template.timer.timeLeft = ->
  Meteor.call 'countdown', null, (error, id) ->
    if error
      return bootbox.alert error.reason

if Meteor.intervalId is undefined
  Meteor.intervalId = Meteor.setInterval Template.timer.timeLeft, 1000

Template.timer.getTimeLeft = ->
  if TimeLeft.findOne() is undefined
    return
  numTotalSeconds = TimeLeft.findOne().secondsLeft
  if numTotalSeconds
    seconds = numTotalSeconds % 60
    minutes = (numTotalSeconds - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return
