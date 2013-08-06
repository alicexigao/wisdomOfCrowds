Template.tutorialRoundAnswers.answers = ->
  tutObj = TutorialData.findOne {userId: Meteor.user()._id}
  return "" unless tutObj
  return tutObj.answers

Template.tutorialRoundAnswers.getAnswer = ->
  if Template.tutorialRoundInputs.shouldDisplayResult()
    return this.answer + "%"
  else
    if this.username is "alice"
      if this.status is "pending"
        return "pending"
      else
        return this.answer + "%"
    else
      tre = Treatment.findOne()
      return "" unless tre
      if tre.displayOtherAnswers
        return this.answer + "%"
      else
        return this.status

Template.tutorialRoundAnswers.usernameIsAlice = ->
  return this.username is "alice"

Template.tutorialRoundAnswers.isWinner = ->
  return false unless Template.tutorialRoundInputs.shouldDisplayResult()

  tutObj = TutorialData.findOne {userId: Meteor.user()._id}
  return "" unless tutObj

  return tutObj.winner is this.answer

Template.tutorialRoundAnswers.shouldDisplayResult = ->
  return Template.tutorialRoundInputs.shouldDisplayResult()

Template.tutorialRoundAnswers.getCorrectAnswer = ->
  tutObj = TutorialData.findOne {userId: Meteor.user()._id}
  return "" unless tutObj
  return tutObj.correctAnswer

Template.tutorialRoundAnswers.shouldDisplayWinner = ->
  tre = Treatment.findOne()
  return null unless tre
  return tre.displayWinner

Template.tutorialRoundAnswers.shouldDisplayAverage = ->
  tre = Treatment.findOne()
  return null unless tre
  return tre.displayAverage

Template.tutorialRoundAnswers.getAverage = ->
  tutObj = TutorialData.findOne {userId: Meteor.user()._id}
  return "" unless tutObj
  avg = parseInt(tutObj.average * 100) / 100
  return avg
