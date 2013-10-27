#    Template.timerFirst.intervalIdMain = Meteor.setInterval Template.timerFirst.countdown, 1000

Template.timerFirst.getTimeLeft = ->
  left = Timers.findOne({name: "first"}).secondsLeft
  if left
    seconds = left % 60
    minutes = (left - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return "0:00"

Template.timerNext.getTimeLeft = ->
  return Timers.findOne({name: "next"}).secondsLeft

