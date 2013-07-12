Meteor.startup ->
  Treatment.remove({})
  Treatment.insert
    value: "pure-competitive"
    displayChatRoom:      false
    displayOtherAnswers:  false
    displayAverage:       false
    displayWinner:        true
    displayCorrectAnswer: true
    displaySecondStage:   false
    pointsRule:           "ownAnswer"

#    value: "cooperative-no-voting"
#    displayChatRoom:      true
#    displayOtherAnswers:  true
#    displayAverage:       true
#    displayWinner:        false
#    displayCorrectAnswer: true
#    displaySecondStage:   false
#    pointsRule:           "average"

#    value: "cooperative-voting"
#    displayChatRoom:      true
#    displayOtherAnswers:  true
#    displayAverage:       false
#    displayWinner:        false
#    displayCorrectAnswer: true
#    displaySecondStage:   true
#    secondStageType:      "voting"
#    pointsRule:           "averageByVotes"

#    value: "competitive-betting"
#    displayChatRoom:      true
#    displayOtherAnswers:  false
#    displayAverage:       false
#    displayWinner:        false
#    displayCorrectAnswer: true
#    displaySecondStage:   true
#    secondStageType:      "betting"
#    pointsRule:           "averageByVotes"


  Rounds.remove({})
  if Rounds.find().count() is 0
    Rounds.insert
      index: 0
      question: "What percent of the world's population lives in the U.S.? (U.S. Census Bureau, International Database, 6/2/2007)"
      correctanswer: 4.57
      answers: {}
      votes: {}
      bets: {}
      status: "inprogress"
    Rounds.insert
      index: 1
      question: "What percent of U.S. households own at least one pet cat? (U.S. Pet Ownership & Demographics Sourcebook, 2002)"
      correctanswer: 31.6
      answers: {}
      votes: {}
      bets: {}
      status: "inprogress"
    Rounds.insert
      index: 2
      question: "What percent of the world's population speaks Spanish as their first language? (Ethnologue: Languages of the World, 4/2007)"
      correctanswer: 4.88
      answers: {}
      votes: {}
      bets: {}
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

  name = "main"
  timerMainDur = 60
  time = new Date()
  endTime = time.getTime() + 1000 * timerMainDur
  time.setTime(endTime)
  if Timers.findOne({name: name})
    Timers.update {name: name},
      $set: {endTime: time}
    Timers.update {name: name},
      $set: {secondsLeft: timerMainDur}
    Timers.update {name: name},
      $set: {start: true}
  else
    Timers.insert
      name: name
      endTime: time
      secondsLeft: timerMainDur
      start: true

  name = "second"
  timerSecondDur = 60
#  time = new Date()
#  endTime = time.getTime() + 1000 * timerSecondDur
#  time.setTime(endTime)
  if Timers.findOne({name: name})
#    Timers.update {name: name},
#      $set: {endTime: time}
    Timers.update {name: name},
      $set: {secondsLeft: timerSecondDur}
    Timers.update {name: name},
      $set: {start: false}
  else
    Timers.insert
      name: name
      endTime: time
      secondsLeft: timerSecondDur
      start: false

  name = "next"
  timerNextDur = 10
  if Timers.findOne({name: name})
    Timers.update {name: name},
      $set: {secondsLeft: timerNextDur}
    Timers.update {name: name},
      $set: {start: false}
  else
    Timers.insert
      name: name
      secondsLeft: timerNextDur
      start: false


  Votes.remove({})

  Bets.remove({})

  ChatMessages.remove({})