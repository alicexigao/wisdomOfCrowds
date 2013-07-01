Template.enterEstimates.events =

  "click #updateEstimate": (ev) ->
    ev.preventDefault()
    estimate = $("input#inputEstimate").val()
    unless estimate
      return

    answerData =
      answer: estimate
      status: "submitted"

    Meteor.call 'updateAnswer', answerData, (error, id) ->
      if error
        return bootbox.alert error.reason

  "click #finalizeEstimate": (ev) ->
    ev.preventDefault()
    estimate = $("input#inputEstimate").val()
    answerData =
      answer: estimate
      status: "finalized"

    Meteor.call 'updateAnswer', answerData, (error, id) ->
      if error
        return bootbox.alert error.reason

    Meteor.call 'saveAnswers', {}, (error, id) ->
      if error
        return bootbox.alert error.reason

    if Template.enterEstimates.allAnswersFinalized()
      Meteor.call 'completeQuestion', {}, (error, id) ->
        if error
          return bootbox.alert error.reason

  "click #nextQuestion": (ev) ->
    ev.preventDefault()

    Meteor.call 'goToNextQuestion', {}, (error, id) ->
      if error
        return bootbox.alert error.reason


# Get info of all online users, sort by usernames
Template.enterEstimates.users = ->
  Meteor.users.find({}, {sort: {username: 1}})

# Check if current user has submitted an answer already
Template.enterEstimates.hasAnswer = ->
  userId = Meteor.user()._id

  return Answers.find({userId: userId}).count() > 0

# Get the answer if it's available, otherwise return Pending
Template.enterEstimates.getAnswer = (uid) ->
  ans = Answers.findOne({userId: uid})
  if ans
    return ans.answer
  else
    return "pending"


# Get the status if it's available, otherwise return pending
Template.enterEstimates.getStatus = (uid) ->
  ans = Answers.findOne({userId: uid})
  if ans and Meteor.user()._id is uid
    return ans.answer
  else if ans
    return ans.status
  else
    return "pending"




# Return whether buttons should be disabled
Template.enterEstimates.isDisabled = ->
  uid = Meteor.user()._id
  ans = Answers.findOne({userId: uid})
  if ans and ans.status is "finalized"
    return "disabled"
  else
    return ""



# Return total number of rounds
Template.enterEstimates.numRounds = ->
  Rounds.find().count()

# Helper method to get index of current round
Template.enterEstimates.getRoundIndex = ->
  currentRoundObj = CurrentRound.findOne()
  if currentRoundObj
    return currentRoundObj.index
  else
    return -1

# Helper method to get object of current round
Template.enterEstimates.getRoundObj = ->
  i = Template.enterEstimates.getRoundIndex()
  if i isnt -1
    roundObj = Rounds.find().fetch()[i]
    if roundObj
      return roundObj
  return -1

# Get index of current round
Template.enterEstimates.getRoundIndexDisplay = ->
  i = Template.enterEstimates.getRoundIndex()
  if i isnt -1
    return i + 1
  return "Error retrieving index of current round"

# Get question for current round
Template.enterEstimates.getQuestion = ->
  round = Template.enterEstimates.getRoundObj()
  if round isnt -1
    return round.question
  return "Error retrieving question"

# Get correct answer for current question
Template.enterEstimates.correctAnswer = ->
  roundObj = Template.enterEstimates.getRoundObj()
  if roundObj isnt -1
    return roundObj.correctanswer
  return "Error retrieving correct answer"


# Return true if all answers are finalized
Template.enterEstimates.allAnswersFinalized = ->
  if Answers.find().count() is 0
    return false
  return Answers.find({status: "finalized"}).count() is Meteor.users.find().count()

Template.enterEstimates.getAverage = ->
  if Template.enterEstimates.allAnswersFinalized()
    ansArray = Answers.find().fetch()
    sum = 0
    for ans in ansArray
      sum = sum + parseInt(ans.answer)
    return sum / ansArray.length

Template.enterEstimates.isBestAnswer = (uid) ->
  return uid is Template.enterEstimates.userIdForBestAnswer()

Template.enterEstimates.userIdForBestAnswer = ->
  if Template.enterEstimates.allAnswersFinalized()
    ansArray = Answers.find().fetch()
    bestId = ""
    bestAnswer = -Infinity
    correctAnswer = Template.enterEstimates.correctAnswer()
    for ans in ansArray
      if Math.abs(ans.answer - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
        bestId = ans.userId
        bestAnswer = ans.answer
    return bestId

