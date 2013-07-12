Template.roundAnswers.events =
  "click input:radio[name=votes]": (ev) ->
    ev.preventDefault()

    voteData =
      userId: Meteor.user()._id
      answerId: this._id

    Meteor.call 'updateVote', voteData, (error, id) ->
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
      Meteor.call 'addBet', betData, (error, id) ->
        if error
          return bootbox.alert error.reason

    else

      betData =
        userId: Meteor.user()._id
        answerId: this._id

      # remove bet
      Meteor.call 'removeBet', betData, (error, id) ->
        if error
          return bootbox.alert error.reason


  "click input:button.increaseBet": (ev) ->
    ev.preventDefault()

    betData =
      userId: Meteor.user()._id
      answerId: this._id
      change: 1

    Meteor.call 'updateBet', betData, (error, id) ->
      if error
        return bootbox.alert error.reason


  "click input:button.decreaseBet": (ev) ->
    ev.preventDefault()

    betData =
      userId: Meteor.user()._id
      answerId: this._id
      change: -1

    Meteor.call 'updateBet', betData, (error, id) ->
      if error
        return bootbox.alert error.reason


Template.roundAnswers.users = ->
  Meteor.users.find({}, {sort: {username: 1}})

Template.roundAnswers.isCurrentUser = ->
  return Meteor.user()._id is this._id

Template.roundAnswers.hasAnswer = ->
  return Answers.find({userId: this._id}).count() > 0

Template.roundAnswers.getAnswer = ->
  ans = Answers.findOne {userId: this._id}
  if ans
    return ans.answer
  else
    return "pending"

Template.roundAnswers.getStatus = ->
  ans = Answers.findOne({userId: this._id})
  if ans and Meteor.user()._id is this._id
    return ans.answer
  else if ans
    return ans.status
  else
    return "pending"

Template.roundAnswers.answerFinalized = ->
  ans = Answers.findOne {userId: this._id}
  return ans and ans.status is "finalized"

Template.roundAnswers.answersFinalized = ->
  return Template.roundInputs.answersFinalized()

Template.roundAnswers.isBestAnswer = ->
  return this._id is Template.roundAnswers.userIdForBestAnswer()

Template.roundAnswers.userIdForBestAnswer = ->
  if Template.roundInputs.answersFinalized()
    ansArray = Answers.find().fetch()
    bestId = ""
    bestAnswer = -Infinity
    correctAnswer = Template.roundInputs.correctAnswer()
    for ans in ansArray
      if Math.abs(ans.answer - correctAnswer) < Math.abs(bestAnswer - correctAnswer)
        bestId = ans.userId
        bestAnswer = ans.answer
  return bestId

Template.roundAnswers.getAverage = ->
  if Template.roundInputs.answersFinalized()
    ansArray = Answers.find().fetch()
    sum = 0
    for ans in ansArray
      sum = sum + parseInt(ans.answer)
  avg = sum / ansArray.length
  avg = parseInt(avg * 100) / 100
  return avg

Template.roundAnswers.correctAnswer = ->
  return Template.roundInputs.correctAnswer()

Template.roundAnswers.displayAnswer = ->
  if this._id is Meteor.user()._id
    return true
  else
    obj = Treatment.findOne()
    if obj
      return obj.displayOtherAnswers

Template.roundAnswers.displayWinner = ->
  obj = Treatment.findOne()
  return unless obj
  return obj.displayWinner

Template.roundAnswers.displayCorrectAnswer = ->
  obj = Treatment.findOne()
  return false unless obj
  if obj.displaySecondStage and Template.roundInputs.votesFinalized()
    return true
  else if !obj.displaySecondStage and Template.roundInputs.answersFinalized()
    return true
  return false

Template.roundAnswers.displayAverage = ->
  obj = Treatment.findOne()
  if obj
    return obj.displayAverage and Template.roundInputs.answersFinalized()

Template.roundAnswers.displaySecondStage = ->
  obj = Treatment.findOne()
  if obj
    return obj.displaySecondStage






Template.roundAnswers.secondStageIsVoting = ->
  return Template.roundInputs.secondStageIsVoting()

Template.roundAnswers.secondStageIsBetting = ->
  return Template.roundInputs.secondStageIsBetting()

Template.roundAnswers.hasVote = (uid) ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  if vote
    return vote.answerId is uid

Template.roundAnswers.voteFinalized = ->
  vote = Votes.findOne {userId: Meteor.user()._id}
  return vote and vote.status is "finalized"

Template.roundAnswers.votesFinalized = ->
  return Template.roundInputs.votesFinalized()

Template.roundAnswers.getNumVotes = ->
  return Votes.find({answerId: this._id}).count()

Template.roundAnswers.displayNumVotes = ->
  return Template.roundAnswers.votesFinalized()

Template.roundAnswers.isCheckedVote = ->
  if Template.roundAnswers.hasVote(this._id)
    return "checked"
  return ""

Template.roundAnswers.betsFinalized = ->
  return Template.roundInputs.betsFinalized()




Template.roundAnswers.getBetAmount = ->
  bet = Bets.findOne {userId: Meteor.user()._id, answerId: this._id}
  if bet
    return "  " + bet.amount
  else return ""

Template.roundAnswers.hasBet = (answerId) ->
  return Bets.findOne {userId: Meteor.user()._id, answerId: answerId}

Template.roundAnswers.isCheckedBet = ->
  if Template.roundAnswers.hasBet(this._id)
    return "checked"
  return ""