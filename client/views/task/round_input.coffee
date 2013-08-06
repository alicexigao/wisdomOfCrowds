Template.roundInputs.events =

  "click #updateEstimate": (ev) ->
    ev.preventDefault()

    ans = $("input#inputEstimate").val().trim()

    # validate answer
    return unless ans
    ansFloat = parseFloat(ans, 10)
    if isNaN(ansFloat) or ansFloat < 0 or ansFloat > 100
      bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
      $("input#inputEstimate").val ""
      return
    else
      ansFloat = Math.round(ansFloat * 100) / 100
      $("input#inputEstimate").val ""

    answerData =
      answer: ansFloat
      status: "submitted"

    Meteor.call 'updateAnswer', answerData, (error, result) ->
      if error
        return bootbox.alert error.reason


  "click #finalizeEstimate": (ev) ->
    ev.preventDefault()

    ans = $("input#inputEstimate").val().trim()

    # validate answer
    ansFloat = parseFloat(ans, 10)
    if ans
      if isNaN(ansFloat) or ansFloat < 0 or ansFloat > 100
        bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
        $("input#inputEstimate").val ""
        return
      else
        $("input#inputEstimate").val ""
        ansFloat = Math.round(ansFloat * 100) / 100
    else
      ansFloat = null

    answerData =
      answer: ansFloat
      status: "finalized"
      userId: Meteor.user()._id

    Meteor.call 'updateAnswer', answerData, (error, result) ->
      if error
        return bootbox.alert error.reason

    if Template.roundInputs.hasTwoStages()
      # has two stages

      if Handlebars._default_helpers.answersFinalized()

        Meteor.call 'stopTimerMain', {}, (error, result) ->
          if error
            return bootbox.alert error.reason

        Meteor.call 'startTimerSecond', {}, (error, result) ->
          if error
            return bootbox.alert error.reason

    else
      # only has one stage
      if Handlebars._default_helpers.answersFinalized()

        Meteor.call 'stopTimerMain', {}, (error, result) ->
          if error
            return bootbox.alert error.reason

        Meteor.call 'markRoundCompleted', {}, (error, result) ->
          if error
            return bootbox.alert error.reason



  "click #finalizeVote": (ev) ->
    ev.preventDefault()

    voteData =
      userId: Meteor.user()._id

    Meteor.call 'finalizeVote', voteData, (error, result) ->
      if error
        return bootbox.alert error.reason

    if Template.roundInputs.votesFinalized()

      Meteor.call 'stopTimerSecond', {}, (error, result) ->
        if error
          return bootbox.alert error.reason

      Meteor.call 'markRoundCompleted', {}, (error, result) ->
        if error
          return bootbox.alert error.reason


  "click #finalizeBet": (ev) ->
    ev.preventDefault()

    betData =
      userId: Meteor.user()._id

    Meteor.call 'finalizeBet', betData, (error, result) ->
      if error
        return bootbox.alert error.reason

    if Template.roundInputs.betsFinalized()

      Meteor.call 'stopTimerSecond', {}, (error, result) ->
        if error
          return bootbox.alert error.reason

      Meteor.call 'markRoundCompleted', {}, (error, result) ->
        if error
          return bootbox.alert error.reason


  "click #goToExitSurvey": (ev) ->
    Meteor.Router.to('/exitsurvey')




###########################
# Functions for stage 1
###########################

Template.roundInputs.hasAnswer = ->
  userId = Meteor.user()._id
  return Answers.find({userId: userId}).count() > 0

Handlebars.registerHelper "answersFinalized", ->
  return Answers.find({status: "finalized"}).count() is Meteor.users.find().count()

Template.roundInputs.isDisabled = ->
  uid = Meteor.user()._id
  ans = Answers.findOne({userId: uid})
  if ans and ans.status is "finalized"
    return "disabled"
  else
    return ""

Template.roundInputs.numRounds = ->
  Rounds.find().count()


Template.roundInputs.readyToRender = ->
  return false unless Treatment.findOne()
  return false unless CurrentRound.findOne()
  i = CurrentRound.findOne().index
  return false unless Rounds.findOne({index: i})

  return true

getRoundIndex = ->
  CurrentRound.findOne().index

Handlebars.registerHelper "getRoundIndex", -> getRoundIndex()

getRoundObj = ->
  i = getRoundIndex()
  Rounds.findOne({index: i})

Handlebars.registerHelper "getRoundObj", -> getRoundObj()

Template.roundInputs.getRoundIndexDisplay = ->
  getRoundIndex() + 1

Template.roundInputs.getQuestion = ->
  getRoundObj().question

Handlebars.registerHelper "correctAnswer", ->
  getRoundObj().correctanswer




###########################
# Functions for stage 2 (voting)
###########################

Template.roundInputs.hasTwoStages = ->
  tre = Treatment.findOne()
  return tre.displaySecondStage

Template.roundInputs.hasVote = ->
  return Votes.findOne {userId: Meteor.user()._id}

Template.roundInputs.votesFinalized = ->
  return Votes.find({status: "finalized"}).count() is Meteor.users.find().count()

Template.roundInputs.isDisabledVote = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  if vote and vote.status is "finalized"
    return "disabled"
  else
    return ""

Template.roundInputs.secondStageIsVoting = ->
  tre = Treatment.findOne()
  return tre.displaySecondStage and tre.secondStageType is "voting"

Template.roundInputs.secondStageIsBetting = ->
  tre = Treatment.findOne()
  return tre.displaySecondStage and tre.secondStageType is "betting"


###########################
# Functions for stage 2 (betting)
###########################

Template.roundInputs.hasBet = ->
  return Bets.findOne {userId: Meteor.user()._id}

Template.roundInputs.isDisabledBet = ->
  bet = Bets.findOne {userId: Meteor.user()._id}
  if bet and bet.status is "finalized"
    return "disabled"
  else
    return ""

Template.roundInputs.betsFinalized = ->
  for user in Meteor.users.find().fetch()
    if Bets.find({userId: user._id}).count() < 1
      return false
  return Bets.find({status: "finalized"}).count() is Bets.find().count()




Template.roundInputs.taskCompleted = ->
  numQuestions = Rounds.find().count()
  round =  Rounds.findOne({index: numQuestions - 1})
  return unless round
  if round.status is "completed"
    clearInterval(Template.timerNext.intervalIdNext)
    clearInterval(Template.timerMain.intervalIdMain)
    clearInterval(Template.timerSecond.intervalIdSecond)
    return true
  return false
