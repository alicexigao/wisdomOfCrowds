
Template.roundResults.users = ->
  return Template.enterEstimates.users()

Template.roundResults.allAnswersFinalized = ->
  return Template.enterEstimates.allAnswersFinalized()

Template.roundResults.isBestAnswer = (uid) ->
  return Template.enterEstimates.isBestAnswer(uid)

Template.roundResults.getAnswer = (uid) ->
  return Template.enterEstimates.getAnswer(uid)

Template.roundResults.hasAnswer = (uid) ->
  return Template.enterEstimates.hasAnswer(uid)

Template.roundResults.getStatus = (uid) ->
  return Template.enterEstimates.getStatus(uid)

Template.roundResults.getAverage = ->
  return Template.enterEstimates.getAverage()

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

Template.roundResults.isCurrentUser = (uid) ->
  return Meteor.user()._id is uid

Template.roundResults.answerFinalized = (uid) ->
  ans = Answers.findOne {userId: uid}
  if ans and ans.status is "finalized"
    return true
  return false