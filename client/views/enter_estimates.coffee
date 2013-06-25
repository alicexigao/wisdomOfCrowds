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

  "click #nextQuestion": (ev) ->
    ev.preventDefault()

    Meteor.call 'saveAnswers', {}, (error, id) ->
      if error
        return bootbox.alert error.reason

    Meteor.call 'incrRoundNum', {}, (error, id) ->
      if error
        return bootbox.alert error.reason



# Get info of all online users, sort by usernames
Template.enterEstimates.users = ->
  Meteor.users.find({}, {sort: {username: 1}})

# Check if current user has submitted an answer already
Template.enterEstimates.hasAnswer = ->
  userId = Meteor.user()._id
  return Answers.find({userId: userId}).count() > 0

# If the user with the given user name has submitted an answer, return it
# Otherwise return "Pending"
Template.enterEstimates.getAnswer = (uid) ->
  ans = Answers.findOne({userId: uid})
  if ans
    return ans.answer
  else
    return "Pending"



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
getCurrRoundIndex = ->
  currentRoundObj = CurrentRound.findOne()
  if currentRoundObj
    return currentRoundObj.index
  else
    return -1

# Helper method to get object of current round
getCurrRoundObj = ->
  i = getCurrRoundIndex()
  if i isnt -1
    roundObj = Rounds.find().fetch()[i]
    if roundObj
      return roundObj
  return -1

# Get index of current round
Template.enterEstimates.getRoundIndex = ->
  i = getCurrRoundIndex()
  if i isnt -1
    return i + 1
  return "Error retrieving index of current round"

# Get question for current round
Template.enterEstimates.getQuestion = ->
  round = getCurrRoundObj()
  if round isnt -1
    return round.question
  return "Error retrieving question"

# Get correct answer for current question
Template.enterEstimates.correctAnswer = ->
  roundObj = getCurrRoundObj()
  if roundObj isnt -1
    return roundObj.correctanswer
  return "Error retrieving correct answer"




# Helper method to check if all answers are finalized
allFinalized = ->
  if Answers.find().count() is 0
    return false
  return Answers.find({status: "finalized"}).count() is Meteor.users.find().count()

# Return true if all answers are finalized
Template.enterEstimates.allAnswersFinalized = ->
  return allFinalized()

Template.enterEstimates.getAverage = ->
  if allFinalized()
#  if Answers.find().count() is 0
#    return 0
#  if Answers.find({status: "finalized"}).count() is Meteor.users.find().count()
    ansArray = Answers.find().fetch()
    sum = 0
    for ans in ansArray
      sum = sum + parseInt(ans.answer)
    return sum / ansArray.length

