
Template.timerNext.countdown = ->
  Meteor.call 'countdownNext', null, (error, id) ->
    if error
      return bootbox.alert error.reason

if Template.timerNext.intervalIdNext is undefined
  Template.timerNext.intervalIdNext = Meteor.setInterval Template.timerNext.countdown, 1000

Template.timerNext.getTimeLeft = ->
  if Timers.findOne({name: "next"}) is undefined
    return
  return Timers.findOne({name: "next"}).secondsLeft

