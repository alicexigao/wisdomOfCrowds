Template.tutorialRoundInputs.events =

  "click #tutorialUpdateEstimate": (ev) ->
    ev.preventDefault()

    ans = $("input#tutorialInputEstimate").val().trim()

    # validate answer
    return unless ans
    ansFloat = parseFloat(ans, 10)
    if isNaN(ansFloat) or ansFloat < 0 or ansFloat > 100
      bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
      $("input#tutorialInputEstimate").val ""
      return
    else
      ansFloat = Math.round(ansFloat * 100) / 100
      $("input#tutorialInputEstimate").val ""

    answerData =
      userId: Meteor.userId()
      answer: ansFloat
      status: "submitted"

    Meteor.call "tutorialUpdateAnswer", answerData, (error, result) ->
      if error
        return bootbox.alert error.reason


  "click #tutorialFinalizeEstimate": (ev) ->
    ev.preventDefault()

    ans = $("input#tutorialInputEstimate").val().trim()

    # validate answer
    ansFloat = parseFloat(ans, 10)
    if ans
      if isNaN(ansFloat) or ansFloat < 0 or ansFloat > 100
        bootbox.alert "Please enter a number in the range of 0 to 100 inclusive."
        $("input#tutorialInputEstimate").val ""
        return
      else
        $("input#tutorialInputEstimate").val ""
        ansFloat = Math.round(ansFloat * 100) / 100
    else
      ansFloat = null

    answerData =
      userId: Meteor.userId()
      answer: ansFloat
      status: "finalized"

    Meteor.call 'tutorialUpdateAnswer', answerData, (error, result) ->
      if error
        return bootbox.alert error.reason



Template.tutorialRoundInputs.hasCurrAnswer = ->
  tutObj = TutorialData.findOne {userId: Meteor.userId()}
  return unless tutObj
  return tutObj.answers[0].answer

Template.tutorialRoundInputs.shouldDisable = ->
  tutObj = TutorialData.findOne {userId: Meteor.userId()}
  return unless tutObj
  if tutObj.answers[0].status is "finalized"
    return "disabled"
  return ""

Template.tutorialRoundInputs.shouldDisplayResult = ->
  tre = Treatment.findOne()
  return false unless tre
  index = Template.tutorial.getIndex()
  if tre.value is "bestPrivate"
    return index >= 3
  else if tre.value is "avgPublicChat"
    return index >= 3

