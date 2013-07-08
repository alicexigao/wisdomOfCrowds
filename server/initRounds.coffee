Meteor.startup ->
  Treatment.remove({})
  Treatment.insert
#    value: "pure-competitive"
#    displayChatRoom:      false
#    displayOtherAnswers:  false
#    displayWinner:        true
#    displayCorrectAnswer: true
#    displayAverage:       false
#    displaySecondStage:       true

#    value: "cooperative-no-voting"
#    displayChatRoom:      true
#    displayOtherAnswers:  true
#    displayWinner:        false
#    displayCorrectAnswer: true
#    displayAverage:       true
#    displaySecondStage:       true

    value: "cooperative-voting"
    displayChatRoom:      true
    displayOtherAnswers:  true
    displayWinner:        false
    displayCorrectAnswer: true
    displayAverage:       false
    displaySecondStage:   true

  Rounds.remove({})
  if Rounds.find().count() is 0
    Rounds.insert
      index: 0
      question: "Population of USA in 2006"
      correctanswer: 55
      answers: {}
      status: "inprogress"
    Rounds.insert
      index: 1
      question: "Population of USA in 2007"
      correctanswer: 40
      answers: {}
      status: "inprogress"
    Rounds.insert
      index: 2
      question: "Population of USA in 2008"
      correctanswer: 35
      answers: {}
      status: "inprogress"

  Answers.remove({})

# Current Round
  CurrentRound.remove({})
  if CurrentRound.find().count() is 0
    CurrentRound.insert index : 0
  else
    CurrentRound.update {},
      $set: {index: 0}

  # Initialize timers
  Timers.remove({})

  timerMainDur = 60
  time = new Date()
  endTime = time.getTime() + 1000 * timerMainDur
  time.setTime(endTime)

  if Timers.findOne({name: "main"})
    Timers.update {name: "main"},
      $set: {endTime: time}
    Timers.update {name: "main"},
      $set: {secondsLeft: timerMainDur}
    Timers.update {name: "main"},
      $set: {start: true}
  else
    Timers.insert
      name: "main"
      endTime: time
      secondsLeft: timerMainDur
      start: true

  timerNextDur = 10
  if Timers.findOne({name: "next"})
    Timers.update {name: "next"},
      $set: {secondsLeft: timerNextDur}
    Timers.update {name: "next"},
      $set: {start: false}
  else
    Timers.insert
      name: "next"
      secondsLeft: timerNextDur
      start: false

  Votes.remove({})