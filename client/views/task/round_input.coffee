Handlebars.registerHelper "treatment", ->
  tre =  Handlebars._default_helpers.tre()
  return unless tre
  tre.value

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

  if not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."

  ansData.answer = roundToTwoDecimals(ans)

  if Session.equals("page", "task")
    Meteor.call 'updateAnswer', ansData, (err, res) ->
      return bootbox.alert err.reason if err
  else
    currUserId = Handlebars._default_helpers.currUserId()
    if TutorialAnswers.findOne {userId: currUserId}
      TutorialAnswers.update {userId: currUserId},
        $set:
          answer: ans
    else
      TutorialAnswers.insert
        userId: currUserId
        answer: ans
        status: "submitted"

finalizeAnsOneStage = (ev) ->
  ans = $("#inputAns").val().trim()
  $("#inputAns").val ""

  ansData =
    status: "finalized"

  if ans and not answerValid(ans)
    return bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."

  if ans and answerValid(ans)
    ansData.answer = roundToTwoDecimals(ans)

  if Session.equals("page", "tutorial")
    currUserId = Handlebars._default_helpers.currUserId()
    if TutorialAnswers.findOne {userId: currUserId}
      if ans
        TutorialAnswers.update {userId: currUserId},
          $set:
            answer: ans
      TutorialAnswers.update {userId: currUserId},
        $set:
          status: ansData.status
    else
      TutorialAnswers.insert
        userId: currUserId
        answer: ans
        status: ansData.status
  else if Session.equals("page", "task")

    Meteor.call 'updateAnswer', ansData, (err, res) ->
      return bootbox.alert err.reason if err

  if Handlebars._default_helpers.answersFinalized()
    if Session.equals("page", "task")

      Meteor.call 'stopTimerFirst'
      Meteor.call 'markRoundCompleted'

    else if Session.equals("page", "tutorial")

      Handlebars._default_helpers.calcBestAnsAndAvg()

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
    Meteor.call 'stopTimerFirst'
    Meteor.call 'startTimerSecond'

#Template.oneStage.rendered = ->
#  # Give focus to the text box when loaded
#  $("#inputAns").focus()

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

readyToRender = ->
  tre = Handlebars._default_helpers.tre()
  return false unless tre
  return false unless Settings.findOne({key: "roundIndex"})
  i = Settings.findOne({key: "roundIndex"}).value
  rounds = Handlebars._default_helpers.rounds()
  return false unless rounds.findOne({index: i})
  return true

Handlebars.registerHelper "readyToRender", -> readyToRender()


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



###########################
# Functions for stage 2 (voting)
###########################

Template.twoStagesVoting.hasVote = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  currUserId = Handlebars._default_helpers.currUserId()
  return Votes.findOne {roundIndex: roundIndex, userId: currUserId}

Handlebars.registerHelper "votesFinalized", ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  usersCursor = Handlebars._default_helpers.users()
  return Votes.find({roundIndex: roundIndex, status: "finalized"}).count() is usersCursor.count()

Template.twoStagesVoting.shouldDisableVoteButton = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  currUserId = Handlebars._default_helpers.currUserId()
  vote = Votes.findOne {roundIndex: roundIndex, userId: currUserId}
  if vote and vote.status is "finalized"
    return "disabled"
  else
    return ""

###########################
# Functions for stage 2 (betting)
###########################

Template.twoStagesBetting.hasBet = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  currUserId = Handlebars._default_helpers.currUserId()
  return Bets.findOne {roundIndex: roundIndex, userId: currUserId}

Handlebars.registerHelper "betsFinalized", ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  usersCursor = Handlebars._default_helpers.users()
  for user in usersCursor.fetch()
    if Bets.find({roundIndex: roundIndex, userId: user._id}).count() < 1
      return false
  return Bets.find({roundIndex: roundIndex, status: "finalized"}).count() is Bets.find({roundIndex: roundIndex}).count()

Template.twoStagesBetting.shouldDisableBetButton = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  currUserId = Handlebars._default_helpers.currUserId()
  bet = Bets.findOne {roundIndex: roundIndex, userId: currUserId}
  if bet and bet.status is "finalized"
    return "disabled"
  else
    return ""



################################
# Check if task is completed
################################

Handlebars.registerHelper "taskCompleted", ->
  rounds = Handlebars._default_helpers.rounds()
  numQuestions = rounds.find().count()
  round =  rounds.findOne({index: numQuestions - 1})
  return unless round
  if round.status is "completed"
    clearInterval(Template.timerNext.intervalIdNext)
    clearInterval(Template.timerFirst.intervalIdMain)
    clearInterval(Template.timerSecond.intervalIdSecond)
    return true
  return false
