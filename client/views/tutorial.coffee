Template.tutorial.events =
  "click #goToQuiz": (ev) ->
    Meteor.Router.to("/quiz")

Template.tutorial.isCooperateNoVoting = ->
  tre = Treatment.findOne()
  if tre and tre.value is "cooperative-no-voting"
    return true
  return false

Template.tutorial.isCooperativeVoting = ->
  tre = Treatment.findOne()
  if tre and tre.value is "cooperative-voting"
    return true
  return false

Template.tutorial.displayOtherAnswers = ->
  tre = Treatment.findOne()
  if tre and tre.displayOtherAnswers is true
    return true
  return false

Template.tutorial.displaySecondStage = ->
  tre = Treatment.findOne()
  if tre and tre.displaySecondStage is true
    return true
  return false

Template.tutorial.secondStageIsVoting = ->
  tre = Treatment.findOne()
  return tre and tre.secondStageType is "voting"

Template.tutorial.pointsRuleIsOwnAnswer = ->
  tre = Treatment.findOne()
  return tre and tre.pointsRule is "ownAnswer"

Template.tutorial.pointsRuleIsAverage = ->
  tre = Treatment.findOne()
  return tre and tre.pointsRule is "average"

Template.tutorial.pointsRuleIsAverageByVotes = ->
  tre = Treatment.findOne()
  return tre and tre.pointsRule is "averageByVotes"