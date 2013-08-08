
Template.answers.treatmentDisplay = (treatment, context) ->
  switch treatment
    when "bestPrivate", "bestChat", "bestPublic", "bestPublicChat", "avgPrivate", "avgChat", "avgPublic", "avgPublicChat"
      return new Handlebars.SafeString Template.ansOneStage(context)
    when "competitive-votebestanswer", "avgPublicChatbyvotes", "competitive-bettingbestanswer", "avgPublicChatbybets"
      return new Handlebars.SafeString Template.roundAnswers(context)


Template.roundAnswers.events =
  "click input:radio[name=votes]": (ev) ->
    ev.preventDefault()

    voteData =
      answerId: @_id

    Meteor.call 'updateVote', voteData, (err, res) ->
      return bootbox.alert err.reason if err

  "click input:checkbox[name=bets]": (ev) ->
    ev.preventDefault()

    answerId = @_id
    if $('input:checkbox#' + answerId).is(':checked')

      if $('input:checkbox[name=bets]:checked').size() > 2
        return bootbox.alert "You can allocate points to at most 2 answers"

      betData =
        answerId: @_id
        amount: 1

      # add bet
      Meteor.call 'addBet', betData, (err, res) ->
        return bootbox.alert err.reason if err

    else

      betData =
        answerId: @_id

      # remove bet
      Meteor.call 'removeBet', betData, (err, res) ->
        return bootbox.alert err.reason if err


  "click input:button.increaseBet": (ev) ->
    ev.preventDefault()

    betData =
      answerId: @_id
      change: 1

    Meteor.call 'updateBet', betData, (err, res) ->
      return bootbox.alert err.reason if err


  "click input:button.decreaseBet": (ev) ->
    ev.preventDefault()

    betData =
      answerId: @_id
      change: -1

    Meteor.call 'updateBet', betData, (err, res) ->
      return bootbox.alert err.reason if err

Handlebars.registerHelper "users", ->
  Meteor.users.find({}, {sort: {rand: 1}})

Handlebars.registerHelper "isCurrentUser", ->
  Meteor.userId() is @_id

# get answer during the break between rounds
Handlebars.registerHelper "getAnsDurBreak", ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  ansObj = Answers.findOne({roundIndex: roundIndex, userId: @_id})
  return ansObj.answer + "%"

# get answer during round
Handlebars.registerHelper "getAnsDurRound", ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  ansObj = Answers.findOne({roundIndex: roundIndex, userId: @_id})
  return "pending" unless ansObj
  if @_id is Meteor.userId()
    # always display current user's answer
    return ansObj.answer + "%"
  else if Treatment.findOne().showOtherAns
    return ansObj.answer + "%"
  else
    return ansObj.status

Handlebars.registerHelper "showBestAnsLabel", ->
  return false unless Handlebars._default_helpers.answersFinalized()
  round = Handlebars._default_helpers.getRoundObj()
  if round.winnerIdArray
    return @_id in round.winnerIdArray
  return false



Template.roundAnswers.isBestAnswer = ->
  round = Handlebars._default_helpers.getRoundObj()
  if round.winnerIdArray
    return @_id in round.winnerIdArray
  return false


Template.correctAns.correctAnswer = ->
  Handlebars._default_helpers.getRoundObj().correctanswer

Template.averageAns.getAverageString = ->
  tre = Handlebars._default_helpers.tre()
  switch tre.pointsRule
      when "average"
        return "average"
      when "averageByVotes"
        return "average by votes"
      when "averageByBets"
        return "average by bets"


Template.averageAns.getAverage = ->
  round = Handlebars._default_helpers.getRoundObj()
  tre = Handlebars._default_helpers.tre()
  if tre.pointsRule is "average"
    avg = round.average
  else if tre.pointsRule is "averageByVotes"
    avg = round.averageByVotes
  else if tre.pointsRule is "averageByBets"
    avg = round.averageByBets
  avg = parseInt(avg * 100) / 100
  return avg

Template.roundAnswers.showBestAns = ->
  obj = Handlebars._default_helpers.tre()
  return obj.showBestAns

Template.roundAnswers.displayCorrectAnswer = ->
  tre = Handlebars._default_helpers.tre()
  if tre.secondStageType is "voting"
    return Handlebars._default_helpers.votesFinalized()
  else if tre.secondStageType is "betting"
    return Handlebars._default_helpers.betsFinalized()
  return false

Template.roundAnswers.showAvg = ->
  tre = Handlebars._default_helpers.tre()
  return false unless tre.showAvg
  if tre.showSecondStage
    if tre.secondStageType is "voting"
      return Handlebars._default_helpers.votesFinalized()
    else if tre.secondStageType is "betting"
      return Handlebars._default_helpers.betsFinalized()
  else
    return Handlebars._default_helpers.answersFinalized()








Template.roundAnswers.secondStageIsVoting = ->
  tre = Handlebars._default_helpers.tre()
  return tre.showSecondStage and tre.secondStageType is "voting"

Template.roundAnswers.secondStageIsBetting = ->
  tre = Handlebars._default_helpers.tre()
  return tre.showSecondStage and tre.secondStageType is "betting"


######################
# With voting
######################

Template.roundAnswers.voteFinalized = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  vote = Votes.findOne {roundIndex: roundIndex, userId: Meteor.userId()}
  return vote and vote.status is "finalized"

Template.roundAnswers.hasVote = (userId) ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  vote = Votes.findOne {roundIndex: roundIndex, userId: Meteor.userId()}
  return vote and (vote.answerId is userId)

Template.roundAnswers.displayNumVotes = ->
  tre = Handlebars._default_helpers.tre()
  if tre
    return tre.showBestAns is false and Template.roundAnswers.votesFinalized()

Template.roundAnswers.getNumVotes = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  return Votes.find({roundIndex: roundIndex, answerId: @_id}).count()

Template.roundAnswers.isCheckedVote = ->
  if Template.roundAnswers.hasVote(@_id)
    return "checked"
  return ""



######################
# With betting
######################

Template.roundAnswers.betFinalized = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  bets = Bets.find({roundIndex: roundIndex, userId: Meteor.userId()}).fetch()
  if bets.length is 0
    return false
  else
    for bet in bets
      if bet.status is "finalized"
        continue
      else
        return false
  return true

Template.roundAnswers.getBetAmount = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  bet = Bets.findOne {roundIndex: roundIndex, userId: Meteor.userId(), answerId: @_id}
  if bet
    return bet.amount
  else return 0

Template.roundAnswers.getTotalBetAmount = ->
  roundIndex = Handlebars._default_helpers.getRoundIndex()
  bets = Bets.find({roundIndex: roundIndex, userId: Meteor.userId()}).fetch()
  return 0 unless bets
  total = 0
  for betObj in bets
    total += betObj.amount
  return total

Template.roundAnswers.allowIncrease = ->
  total = Template.roundAnswers.getTotalBetAmount()
  return total < 10

ansHasBet = (answerId) ->
  return Bets.findOne {roundIndex: roundIndex, userId: Meteor.userId(), answerId: answerId}

Template.roundAnswers.isCheckedBet = ->
  if Template.roundAnswers.ansHasBet(@_id)
    return "checked"
  return ""

Template.roundAnswers.getDisabledStrForAnsIncrease = ->
  if Template.roundAnswers.ansHasBet(@_id) and Template.roundAnswers.allowIncrease()
    return ""
  else return "disabled"

Template.roundAnswers.getDisabledStrForAnsDecrease = ->
  if Template.roundAnswers.ansHasBet(@_id)
    return ""
  else return "disabled"


