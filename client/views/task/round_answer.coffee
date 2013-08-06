Template.roundAnswer.events =
  "click input:radio[name=votes]": (ev) ->
    ev.preventDefault()

    voteData =
      userId: Meteor.user()._id
      answerId: this._id

    Meteor.call 'updateVote', voteData, (error, result) ->
      if error
        return bootbox.alert error.reason

  "click input:checkbox[name=bets]": (ev) ->
    ev.preventDefault()

    answerId = this._id
    if $('input:checkbox#' + answerId).is(':checked')

      if $('input:checkbox[name=bets]:checked').size() > 2
        return bootbox.alert "You can allocate points to at most 2 answers"

      betData =
        userId: Meteor.user()._id
        answerId: this._id
        amount: 1

      # add bet
      Meteor.call 'addBet', betData, (error, result) ->
        if error
          return bootbox.alert error.reason

    else

      betData =
        userId: Meteor.user()._id
        answerId: this._id

      # remove bet
      Meteor.call 'removeBet', betData, (error, result) ->
        if error
          return bootbox.alert error.reason


  "click input:button.increaseBet": (ev) ->
    ev.preventDefault()

    betData =
      userId: Meteor.user()._id
      answerId: this._id
      change: 1

    Meteor.call 'updateBet', betData, (error, result) ->
      if error
        return bootbox.alert error.reason


  "click input:button.decreaseBet": (ev) ->
    ev.preventDefault()

    betData =
      userId: Meteor.user()._id
      answerId: this._id
      change: -1

    Meteor.call 'updateBet', betData, (error, result) ->
      if error
        return bootbox.alert error.reason


Template.roundAnswers.readyToRender = ->
  return false unless Treatment.findOne()
  return false unless CurrentRound.findOne()
  i = CurrentRound.findOne().index
  return false unless Rounds.findOne({index: i})

  return true

Template.roundAnswer.users = ->
  Meteor.users.find({}, {sort: {rand: 1}})

Template.roundAnswer.isCurrentUser = ->
  return Meteor.user()._id is this._id

Template.roundAnswer.hasAnswer = ->
  return Answers.findOne({userId: this._id})

Template.roundAnswer.getAnswer = ->
  ans = Answers.findOne {userId: this._id}
  if ans
    return ans.answer
  else
    return "pending"

Template.roundAnswer.getStatus = ->
  ans = Answers.findOne({userId: this._id})
  if ans and Meteor.user()._id is this._id
    return ans.answer
  else if ans
    return ans.status
  else
    return "pending"

Template.roundAnswer.answerFinalized = ->
  ans = Answers.findOne {userId: this._id}
  return ans and ans.status is "finalized"

Template.roundAnswer.isBestAnswer = ->
  round = Handlebars._default_helpers.getRoundObj()
  if round.winnerIdArray
    return this._id in round.winnerIdArray
  return false


Template.roundAnswer.getAverageString = ->
  tre = Treatment.findOne()
  if tre.pointsRule is "average"
    return "average"
  else if tre.pointsRule is "averageByVotes"
    return "average by votes"
  else if tre.pointsRule is "averageByBets"
    return "average by bets"

Template.roundAnswer.getAverage = ->
  round =   round = Handlebars._default_helpers.getRoundObj()
  tre = Treatment.findOne()
  if tre.pointsRule is "average"
    avg = round.average
  else if tre.pointsRule is "averageByVotes"
    avg = round.averageByVotes
  else if tre.pointsRule is "averageByBets"
    avg = round.averageByBets
  avg = parseInt(avg * 100) / 100
  return avg

Template.roundAnswer.displayAnswer = ->
  if this._id is Meteor.user()._id
    return true
  else
    obj = Treatment.findOne()
    return obj.displayOtherAnswers

Template.roundAnswer.displayWinner = ->
  obj = Treatment.findOne()
  return obj.displayWinner

Template.roundAnswer.displayCorrectAnswer = ->
  obj = Treatment.findOne()
  if obj.displaySecondStage
    if obj.secondStageType is "voting"
      return Template.roundInputs.votesFinalized()
    else if obj.secondStageType is "betting"
      return Template.roundInputs.betsFinalized()
  else
    return Handlebars._default_helpers.answersFinalized()
  return false

Template.roundAnswer.displayAverage = ->
  obj = Treatment.findOne()
  return false unless obj.displayAverage
  if obj.displaySecondStage
    if obj.secondStageType is "voting"
      return Template.roundInputs.votesFinalized()
    else if obj.secondStageType is "betting"
      return Template.roundInputs.betsFinalized()
  else
    return Handlebars._default_helpers.answersFinalized()



Template.roundAnswer.displaySecondStage = ->
  obj = Treatment.findOne()
  return obj.displaySecondStage





Template.roundAnswer.secondStageIsVoting = ->
  return Template.roundInputs.secondStageIsVoting()

Template.roundAnswer.secondStageIsBetting = ->
  return Template.roundInputs.secondStageIsBetting()

Template.roundAnswer.hasVote = (uid) ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  if vote
    return vote.answerId is uid

Template.roundAnswer.voteFinalized = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  return vote and vote.status is "finalized"

Template.roundAnswer.votesFinalized = ->
  return Template.roundInputs.votesFinalized()

Template.roundAnswer.getNumVotes = ->
  return Votes.find({answerId: this._id}).count()

Template.roundAnswer.displayNumVotes = ->
  tre = Treatment.findOne()
  if tre
    return tre.displayWinner is false and Template.roundAnswer.votesFinalized()

Template.roundAnswer.isCheckedVote = ->
  if Template.roundAnswer.hasVote(this._id)
    return "checked"
  return ""




Template.roundAnswer.betFinalized = ->
  bets = Bets.find({userId: Meteor.user()._id}).fetch()
  if bets.length is 0
    return false
  else
    for bet in bets
      if bet.status is "finalized"
        continue
      else
        return false
  return true

Template.roundAnswer.betsFinalized = ->
  return Template.roundInputs.betsFinalized()

Template.roundAnswer.getBetAmount = ->
  bet = Bets.findOne {userId: Meteor.user()._id, answerId: this._id}
  if bet
    return bet.amount
  else return 0

Template.roundAnswer.hasBet = (answerId) ->
  return Bets.findOne {userId: Meteor.user()._id, answerId: answerId}

Template.roundAnswer.isCheckedBet = ->
  if Template.roundAnswer.hasBet(this._id)
    return "checked"
  return ""


Template.roundAnswer.getDisabledStringIncrease = ->
  if Template.roundAnswer.hasBet(this._id) and Template.roundAnswer.allowIncrease()
    return ""
  else return "disabled"

Template.roundAnswer.getDisabledStringDecrease = ->
  if Template.roundAnswer.hasBet(this._id)
    return ""
  else return "disabled"

Template.roundAnswer.getTotalBetAmount = ->
  bets = Bets.find({userId: Meteor.user()._id}).fetch()
  return 0 unless bets
  total = 0
  for betObj in bets
    total += betObj.amount
  return total

Template.roundAnswer.allowIncrease = ->
  total = Template.roundAnswer.getTotalBetAmount()
  return total < 10

