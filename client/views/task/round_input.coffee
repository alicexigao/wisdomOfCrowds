Handlebars.registerHelper "treatment", ->
  tre =  Handlebars._default_helpers.tre()
  return unless tre
  tre.value

Handlebars.registerHelper "context", ->

Template.round.treatmentDisplay = (treatment, context) ->
  switch treatment
    when "bestPrivate", "bestChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgChat", "avgPublic", "avgPublicChat"
      return new Handlebars.SafeString Template.oneStage(context)


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

  currUserId = Handlebars._default_helpers.currUserId()
  roundIndex = Handlebars._default_helpers.getRoundIndex()

  ansData =
    roundIndex: roundIndex
    userId    : currUserId
    status    : "submitted"
    page      : Session.get("page")

  if not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."

  ansData.answer = roundToTwoDecimals(ans)

  Meteor.call 'updateAnswer', ansData, (err, res) ->
    return bootbox.alert err.reason if err

#  if Session.equals("page", "task")
#    Meteor.call 'updateAnswer', ansData, (err, res) ->
#      return bootbox.alert err.reason if err
#  else
#    if TutorialAnswers.findOne {roundIndex: roundIndex, userId: currUserId}
#      TutorialAnswers.update {roundIndex: roundIndex, userId: currUserId},
#        $set:
#          answer: ans
#    else
#      TutorialAnswers.insert
#        roundIndex: roundIndex
#        userId: currUserId
#        answer: ans
#        status: "submitted"

finalizeAnsOneStage = (ev) ->
  ans = $("#inputAns").val().trim()
  $("#inputAns").val ""

  roundIndex = Handlebars._default_helpers.getRoundIndex()
  currUserId = Handlebars._default_helpers.currUserId()

  ansData =
    roundIndex: roundIndex
    userId    : currUserId
    status    : "finalized"
    page      : Session.get("page")

  if ans and not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
  if ans and answerValid(ans)
    ansData.answer = roundToTwoDecimals(ans)

  Meteor.call 'updateAnswer', ansData, (err, res) ->
    return bootbox.alert err.reason if err

  if Handlebars._default_helpers.answersFinalized()
    if Session.equals("page", "task")

      Meteor.call 'endCurrRound'

    else if Session.equals("page", "tutorial")

      Handlebars._default_helpers.calcBestAnsAndAvg()

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


###########################
# Functions for stage 1
###########################
Handlebars.registerHelper "currUserHasAns", ->
  currUserId = Handlebars._default_helpers.currUserId()
  return Handlebars._default_helpers.ansObjForId(currUserId)

Handlebars.registerHelper "currAnsFinalized", ->
  currUserId = Handlebars._default_helpers.currUserId()
  ans = Handlebars._default_helpers.ansObjForId(currUserId)
  return ans and ans.status is "finalized"

Handlebars.registerHelper "getDisabledStrForAns", ->
  if Handlebars._default_helpers.currAnsFinalized()
    return "disabled"
  else
    return ""




################################
# Check if task is completed
################################

Handlebars.registerHelper "taskCompleted", ->
  numQuestions = Rounds.find().count()
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  return numQuestions is (roundIndex + 1)
