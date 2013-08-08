Handlebars.registerHelper "treatment", ->
  return unless Treatment.findOne()
  Treatment.findOne().value

Handlebars.registerHelper "context", ->

Template.round.treatmentDisplay = (treatment, context) ->
  switch treatment
    when "bestPrivate", "bestChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgChat", "avgPublic", "avgPublicChat"
      return new Handlebars.SafeString Template.oneStage(context)
    when "competitive-votebestanswer", "avgPublicChatbyvotes"
      return new Handlebars.SafeString Template.twoStagesVoting(context)
    when "competitive-bettingbestanswer", "avgPublicChatbybets"
      return new Handlebars.SafeString Template.twoStagesBetting(context)


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

  ansData =
    status: "submitted"

  if answerValid(ans)
    ansData.answer = roundToTwoDecimals(ans)
    Meteor.call 'updateAnswer', ansData, (err, res) ->
      return bootbox.alert err.reason if err
  else
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."

finalizeAnsOneStage = (ev) ->
  ans = $("#inputAns").val().trim()
  $("#inputAns").val ""

  ansData =
    status: "finalized"
  if ans
    if answerValid(ans)
      ansData.answer = roundToTwoDecimals(ans)
      Meteor.call 'updateAnswer', ansData, (err, res) ->
        return bootbox.alert err.reason if err
    else
      return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
  else
    Meteor.call 'updateAnswer', ansData, (err, res) ->
      return bootbox.alert err.reason if err

  if Handlebars._default_helpers.answersFinalized()
    Meteor.call 'stopTimerMain'
    Meteor.call 'markRoundCompleted'

finalizeAnsTwoStages = (ev) ->
  ans = $("#inputAns").val().trim()
  $("#inputAns").val ""

  ansData =
    status: "finalized"
  if ans
    if answerValid(ans)
      ansData.answer = roundToTwoDecimals(ans)
      Meteor.call 'updateAnswer', ansData, (err, res) ->
        return bootbox.alert err.reason if err
    else
      return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
  else
    Meteor.call 'updateAnswer', ansData, (err, res) ->
      return bootbox.alert err.reason if err

  if Handlebars._default_helpers.answersFinalized()
    Meteor.call 'stopTimerMain'
    Meteor.call 'startTimerSecond'


Template.oneStage.rendered = ->
  # Give focus to the text box when loaded
  $("#inputAns").focus()


Template.twoStagesVoting.rendered = ->
  # Give focus to the text box when loaded
  $("#inputAns").focus()


Template.twoStagesBetting.rendered = ->
  # Give focus to the text box when loaded
  $("#inputAns").focus()

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
    Meteor.Router.to('/exitsurvey')

Template.twoStagesVoting.events =

  "keydown #inputAns": (ev) ->
    return unless ev.keyCode is 13
    ev.preventDefault()
    updateAnswer(ev)

  "click #updateAns": (ev) ->
    ev.preventDefault()
    updateAnswer(ev)

  "click #finalizeAns": (ev) ->
    ev.preventDefault()
    finalizeAnsTwoStages(ev)

  "click #finalizeVote": (ev) ->
    ev.preventDefault()

    Meteor.call 'finalizeVote'
    if Handlebars._default_helpers.votesFinalized()
      Meteor.call 'stopTimerSecond'
      Meteor.call 'markRoundCompleted'

  "click #goToExitSurvey": (ev) ->
    Meteor.Router.to('/exitsurvey')

Template.twoStagesBetting.events =

  "keydown #inputAns": (ev) ->
    return unless ev.keyCode is 13
    ev.preventDefault()
    updateAnswer(ev)

  "click #updateAns": (ev) ->
    ev.preventDefault()
    updateAnswer(ev)

  "click #finalizeAns": (ev) ->
    ev.preventDefault()
    finalizeAnsTwoStages(ev)

  "click #finalizeBet": (ev) ->
    ev.preventDefault()

    Meteor.call 'finalizeBet'
    if Handlebars._default_helpers.betsFinalized()
      Meteor.call 'stopTimerSecond'
      Meteor.call 'markRoundCompleted'

  "click #goToExitSurvey": (ev) ->
    Meteor.Router.to('/exitsurvey')



getRoundIndex = ->
  return unless CurrentRound.findOne()
  CurrentRound.findOne().index

Handlebars.registerHelper "getRoundIndex", -> getRoundIndex()

getRoundObj = ->
  i = getRoundIndex()
  Rounds.findOne({index: i})

Handlebars.registerHelper "getRoundObj", -> getRoundObj()




readyToRender = ->
  return false unless Treatment.findOne()
  return false unless CurrentRound.findOne()
  i = CurrentRound.findOne().index
  return false unless Rounds.findOne({index: i})
  return true

Handlebars.registerHelper "readyToRender", -> readyToRender()


###########################
# Functions for stage 1
###########################
Handlebars.registerHelper "currUserHasAns", ->
  roundIndex = getRoundIndex()
  return Answers.findOne({roundIndex: roundIndex, userId: Meteor.userId()})

Handlebars.registerHelper "answersFinalized", ->
  roundIndex = getRoundIndex()
  return Answers.find({roundIndex: roundIndex, status: "finalized"}).count() is Meteor.users.find().count()

Handlebars.registerHelper "currAnsFinalized", ->
  roundIndex = getRoundIndex()
  ans = Answers.findOne({roundIndex: roundIndex, userId: Meteor.userId()})
  return ans and ans.status is "finalized"

Handlebars.registerHelper "getDisabledStrForAns", ->
  if Handlebars._default_helpers.currAnsFinalized()
    return "disabled"
  else
    return ""





###########################
# Functions for stage 2 (voting)
###########################

Template.twoStagesVoting.hasVote = ->
  roundIndex = getRoundIndex()
  return Votes.findOne {roundIndex: roundIndex, userId: Meteor.userId()}

Handlebars.registerHelper "votesFinalized", ->
  roundIndex = getRoundIndex()
  return Votes.find({roundIndex: roundIndex, status: "finalized"}).count() is Meteor.users.find().count()

Template.twoStagesVoting.shouldDisableVoteButton = ->
  roundIndex = getRoundIndex()
  vote = Votes.findOne {roundIndex: roundIndex, userId: Meteor.userId()}
  if vote and vote.status is "finalized"
    return "disabled"
  else
    return ""

###########################
# Functions for stage 2 (betting)
###########################

Template.twoStagesBetting.hasBet = ->
  roundIndex = getRoundIndex()
  return Bets.findOne {roundIndex: roundIndex, userId: Meteor.userId()}

Handlebars.registerHelper "betsFinalized", ->
  roundIndex = getRoundIndex()
  for user in Meteor.users.find().fetch()
    if Bets.find({roundIndex: roundIndex, userId: user._id}).count() < 1
      return false
  return Bets.find({roundIndex: roundIndex, status: "finalized"}).count() is Bets.find({roundIndex: roundIndex}).count()

Template.twoStagesBetting.shouldDisableBetButton = ->
  roundIndex = getRoundIndex()
  bet = Bets.findOne {roundIndex: roundIndex, userId: Meteor.userId()}
  if bet and bet.status is "finalized"
    return "disabled"
  else
    return ""



################################
# Check if task is completed
################################

Handlebars.registerHelper "taskCompleted", ->
  numQuestions = Rounds.find().count()
  round =  Rounds.findOne({index: numQuestions - 1})
  return unless round
  if round.status is "completed"
    clearInterval(Template.timerNext.intervalIdNext)
    clearInterval(Template.timerMain.intervalIdMain)
    clearInterval(Template.timerSecond.intervalIdSecond)
    return true
  return false
