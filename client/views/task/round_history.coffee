Template.history.rounds = ->
  Rounds.find({}, {sort: {index: 1}})

Template.history.isRoundFinished = (round) ->
  return round.status is "completed"

Template.history.getIndex = ->
  if Template.history.isRoundFinished(this)
    return this.index + 1
  return ""

Template.history.getMyAnswer = ->
  uid = Meteor.user()._id
  if Template.history.isRoundFinished(this)
    return this.answers[uid].answer
  return ""

Template.history.getCorrectAnswer = ->
  if Template.history.isRoundFinished(this)
    return this.correctanswer
  return ""

Template.history.displayPercentageSign = (round) ->
  if Template.history.isRoundFinished(round)
    return "%"
  return ""