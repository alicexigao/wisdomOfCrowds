Template.timerFirst.readyToRender = ->
  return false unless Timers.findOne(
    name: "first"
  )
  return true

Template.timerFirst.countdown = ->
  Meteor.call 'countdownFirst', {}, (err, res) ->
    return bootbox.alert err.reason if err

if Template.timerFirst.intervalIdMain is undefined
  Template.timerFirst.intervalIdMain = Meteor.setInterval Template.timerFirst.countdown, 1000

Template.timerFirst.getTimeLeft = ->
  numTotalSeconds = Timers.findOne(
    name: "first"
  ).secondsLeft

  if numTotalSeconds
    seconds = numTotalSeconds % 60
    minutes = (numTotalSeconds - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return "0:00"




Template.timerSecond.countdown = ->
  Meteor.call 'countdownSecond', null, (err, res) ->
    return bootbox.alert err.reason if err

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




Template.timerNext.countdown = ->
  Meteor.call 'countdownNext', null, (error, result) ->
    if error
      return bootbox.alert error.reason

if Template.timerNext.intervalIdNext is undefined
  Template.timerNext.intervalIdNext = Meteor.setInterval Template.timerNext.countdown, 1000

Template.timerNext.getTimeLeft = ->
  if Timers.findOne({name: "next"}) is undefined
    return
  return Timers.findOne({name: "next"}).secondsLeft

