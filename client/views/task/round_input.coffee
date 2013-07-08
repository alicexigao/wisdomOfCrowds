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

    data =
      userId: Meteor.user()._id
    Meteor.call 'saveAnswers', data, (error, id) ->
      if error
        return bootbox.alert error.reason

    if not Template.enterEstimates.hasTwoStages() and Template.enterEstimates.answersFinalized()

      Meteor.call 'stopTimerMain', {}, (error, id) ->
        if error
          return bootbox.alert error.reason

      Meteor.call 'markRoundCompleted', {}, (error, id) ->
        if error
          return bootbox.alert error.reason

  "click #finalizeVote": (ev) ->
    ev.preventDefault()

    voteData =
      userId: Meteor.user()._id
    Meteor.call 'finalizeVote', voteData, (error, id) ->
      if error
        return bootbox.alert error.reason

    # Save finalized vote

    if Template.enterEstimates.votesFinalized()

      Meteor.call 'stopTimerMain', {}, (error, id) ->
        if error
          return bootbox.alert error.reason

      Meteor.call 'markRoundCompleted', {}, (error, id) ->
        if error
          return bootbox.alert error.reason


Template.enterEstimates.hasAnswer = ->
  userId = Meteor.user()._id
  return Answers.find({userId: userId}).count() > 0

Template.enterEstimates.isDisabled = ->
  uid = Meteor.user()._id
  ans = Answers.findOne({userId: uid})
  if ans and ans.status is "finalized"
    return "disabled"
  else
    return ""

Template.enterEstimates.numRounds = ->
  Rounds.find().count()

Template.enterEstimates.getRoundIndex = ->
  currentRoundObj = CurrentRound.findOne()
  if currentRoundObj
    return currentRoundObj.index
  else
    return -1

Template.enterEstimates.getRoundObj = ->
  i = Template.enterEstimates.getRoundIndex()
  if i isnt -1
    roundObj = Rounds.find().fetch()[i]
    if roundObj
      return roundObj
  return -1

Template.enterEstimates.getRoundIndexDisplay = ->
  i = Template.enterEstimates.getRoundIndex()
  if i isnt -1
    return i + 1
  return "Error retrieving index of current round"

Template.enterEstimates.getQuestion = ->
  round = Template.enterEstimates.getRoundObj()
  if round isnt -1
    return round.question
  return "Error retrieving question"

Template.enterEstimates.correctAnswer = ->
  roundObj = Template.enterEstimates.getRoundObj()
  if roundObj isnt -1
    return roundObj.correctanswer
  return "Error retrieving correct answer"

Template.enterEstimates.answersFinalized = ->
#  if Answers.find().count() is 0
#    return false
  return Answers.find({status: "finalized"}).count() is Meteor.users.find().count()




Template.enterEstimates.hasVote = ->
  return Votes.findOne {userId: Meteor.user()._id}
#  if Votes.findOne {userId: Meteor.user()._id}
#    return true
#  return false

Template.enterEstimates.isDisabledVote = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  if vote and vote.status is "finalized"
    return "disabled"
  else
    return ""

Template.enterEstimates.votesFinalized = ->
  return Votes.find({status: "finalized"}).count() is Meteor.users.find().count()

Template.enterEstimates.hasTwoStages = ->
  obj = Treatment.findOne()
  if obj
    return obj.displaySecondStage