Template.enterEstimates.events =
  "click #updateEstimate": (ev) ->
    ev.preventDefault()
    estimate = $("input#inputEstimate").val()
    updateAnswer(estimate, false)

  "click #finalizeEstimate": (ev) ->
    ev.preventDefault()
    estimate = $("input#inputEstimate").val()
    updateAnswer(estimate, true)

updateAnswer = (estimate, finalized) ->
  answerData =
    answer: estimate
    finalized: finalized

  Meteor.call 'updateAnswer', answerData, (error, id) ->
    if error
      return alert(error.reason)

Template.enterEstimates.usernames = ->
  Meteor.users.find({}, {sort: {username: 1}})

Template.enterEstimates.hasAnswer = ->
  name = Meteor.user().username
  return Answers.find({username: name}).count() > 0

Template.enterEstimates.getAnswer = (name) ->
  if Answers.find({username: name}).count() > 0
    answerData = Answers.findOne {username: name},
      fields:
        answer: 1
    return answerData.answer
  else
    return "Pending"

Template.enterEstimates.isDisabled = ->
  name = Meteor.user().username
  if Answers.find({username: name}).count() is 0
    return ""
  state = Answers.findOne {username: name},
    fields:
      finalized: 1

  if state.finalized is true
    return "disabled"
  else
    return ""