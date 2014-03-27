Template.timerFirst.getTimeLeft = ->
  groupId = TurkServer.group()
  left = Rounds.findOne({_groupId: groupId, active: true}).secondsLeft
  if left
    seconds = left % 60
    minutes = (left - seconds) / 60
    if seconds < 10
      return minutes + ":0" + seconds
    else
      return minutes + ":" + seconds
  return "0:00"

Template.timerNext.getTimeLeft = ->
  groupId = TurkServer.group()
  left = Rounds.findOne({_groupId: groupId, active: true}).secondsLeft
  return "0" unless left
  return left


