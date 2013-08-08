Template.tutorialRoundHistory.getAliceAnswer = ->
  tutObj = TutorialData.findOne({userId: Meteor.userId()})
  return "" unless tutObj
  if tutObj.answers[0].answer is null
    return 50 + "%"
  return tutObj.answers[0].answer + "%"

Template.tutorialRoundHistory.getCorrectAnswer = ->
  tutObj = TutorialData.findOne({userId: Meteor.userId()})
  return "" unless tutObj
  return tutObj.correctAnswer + "%"

Template.tutorialRoundHistory.getWinningAnswer = ->
  tutObj = TutorialData.findOne({userId: Meteor.userId()})
  return "" unless tutObj
  return tutObj.winner + "%"

Template.tutorialRoundHistory.getAverage = ->
  tutObj = TutorialData.findOne({userId: Meteor.userId()})
  return "" unless tutObj
  avg = parseInt(tutObj.average * 100) / 100
  return avg + "%"

Template.tutorialRoundHistory.calcPoints = ->
  tutObj = TutorialData.findOne({userId: Meteor.userId()})
  return "" unless tutObj

  tre = Treatment.findOne()
  return "" unless tre

  if tre.pointsRule is "ownAnswer"
    if tutObj.answers[0].answer is tutObj.winner
      return 100
    else
      return 10
  else if tre.pointsRule is "average"
    points = 110 - 2 * Math.abs(tutObj.average - tutObj.answers[0].answer)
    points = parseInt(points * 100) / 100
    return points

Template.tutorialRoundHistory.shouldDisplayResult = ->
  return Template.tutorialRoundInputs.shouldDisplayResult()

Template.tutorialRoundHistory.shouldDisplayWinner = ->
  return Template.tutorialRoundAnswers.shouldDisplayWinner()



