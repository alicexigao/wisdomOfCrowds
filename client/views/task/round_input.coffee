Template.round.treatmentDisplay = (treatment) ->
  switch TurkServer.treatment()
    when "bestPrivate", "bestPrivateChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgPrivateChat", "avgPublic", "avgPublicChat"
      return Template.oneStage
    else return null

answerValid = (ans) ->
  ansFloat = parseFloat(ans, 10)
  return false if isNaN(ansFloat) or ansFloat < 0 or ansFloat > 100
  true

roundToTwoDecimals = (ans) ->
  ansFloat = parseFloat(ans, 10)
  Math.round(ansFloat * 100) / 100

updateAnswer = (ev) ->
  ans = $("#inputAns").val().trim()
  return unless ans

  $("#inputAns").val ""

  currUserId = Util.getCurrUserId()
  roundIndex = Util.getRoundIndex()

  ansData =
    roundIndex: roundIndex
    userId: currUserId
    status: "submitted"

  if not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."

  ansData.answer = roundToTwoDecimals(ans)

  Meteor.call 'updateAnswer', ansData, (err, res) ->
    return bootbox.alert err.reason if err

finalizeAnsOneStage = (ev) ->
  ans = $("#inputAns").val().trim()
  $("#inputAns").val ""

  roundIndex = Util.getRoundIndex()
  currUserId = Util.getCurrUserId()

  ansData =
    roundIndex: roundIndex
    userId: currUserId
    status: "finalized"

  if ans and not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
  if ans and answerValid(ans)
    ansData.answer = roundToTwoDecimals(ans)

  Meteor.call 'updateAnswer', ansData, (err, res) ->
    return bootbox.alert err.reason if err

Template.oneStage.events =

  "keydown #inputAns": (ev) ->
    return unless ev.keyCode is 13
    ev.preventDefault()
    updateAnswer(ev)

  "click #updateAns": (ev) ->
    ev.preventDefault()
    updateAnswer(ev)

  "click #finalizeAns": (ev) ->
    ev.preventDefault()
    finalizeAnsOneStage(ev)

  "click #goToExitSurvey": (ev) ->
    Router.go('/exitsurvey')

Handlebars.registerHelper "currUserHasAns", ->
  currUserId = Util.getCurrUserId()
  return Util.ansObjForId(currUserId)

currAnsFinalized = ->
  currUserId = Util.getCurrUserId()
  ans = Util.ansObjForId(currUserId)
  return ans and ans.status is "finalized"

Handlebars.registerHelper "getDisabledStrForAns", ->
  if currAnsFinalized()
    "disabled"
  else
    ""

Handlebars.registerHelper "taskCompleted", ->
  numQuestions = Rounds.find().count()
  roundIndex = Util.getRoundIndex()
  return numQuestions is (roundIndex + 1)
