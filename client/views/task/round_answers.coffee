Template.roundResults.events =
  "click .answerbadges": (ev) ->
    voteData =
      userId: Meteor.user()._id
      answerId: this._id

    Meteor.call 'updateVote', voteData, (error, id) ->
      if error
        return bootbox.alert error.reason

Template.roundResults.users = ->
  Meteor.users.find({}, {sort: {username: 1}})

Template.roundResults.answersFinalized = ->
  return Template.enterEstimates.answersFinalized()

Template.roundResults.isBestAnswer = ->
  return this._id is Template.roundResults.userIdForBestAnswer()

Template.roundResults.userIdForBestAnswer = ->
  if Template.enterEstimates.answersFinalized()
    ansArray = Answers.find().fetch()
    bestId = ""
    bestAnswer = -Infinity
    correctAnswer = Template.enterEstimates.correctAnswer()
    for ans in ansArray
      if Math.abs(ans.answer - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
        bestId = ans.userId
        bestAnswer = ans.answer
  return bestId

Template.roundResults.hasAnswer = ->
  return Answers.find({userId: this._id}).count() > 0

Template.roundResults.getAnswer = ->
  ans = Answers.findOne {userId: this._id}
  if ans
    return ans.answer
  else
    return "pending"

Template.roundResults.getStatus = ->
  ans = Answers.findOne({userId: this._id})
  if ans and Meteor.user()._id is this._id
    return ans.answer
  else if ans
    return ans.status
  else
    return "pending"

Template.roundResults.getAverage = ->
  if Template.enterEstimates.answersFinalized()
    ansArray = Answers.find().fetch()
    sum = 0
    for ans in ansArray
      sum = sum + parseInt(ans.answer)
  return sum / ansArray.length

Template.roundResults.correctAnswer = ->
  return Template.enterEstimates.correctAnswer()

# Return true if answer for user with id uid should be displayed
Template.roundResults.displayAnswer = (uid) ->
  if uid is Meteor.user()._id
    return true
  else
    obj = Treatment.findOne()
    if obj
      return obj.displayOtherAnswers

# Returns true if winner should be displayed
Template.roundResults.displayWinner = ->
  obj = Treatment.findOne()
  if obj
    return obj.displayWinner

Template.roundResults.displayAverage = ->
  obj = Treatment.findOne()
  if obj
    return obj.displayAverage

Template.roundResults.displaySecondStage = ->
  obj = Treatment.findOne()
  if obj
    return obj.displaySecondStage

Template.roundResults.isCurrentUser = (uid) ->
  return Meteor.user()._id is uid

Template.roundResults.answerFinalized = (uid) ->
  ans = Answers.findOne {userId: uid}
  if ans and ans.status is "finalized"
    return true
  return false

Template.roundResults.hasVote = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  if vote
    return vote.answerId is this._id

Template.roundResults.voteFinalized = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  return vote and vote.status is "finalized"
