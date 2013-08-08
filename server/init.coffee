Meteor.startup ->
  Treatment.remove({})
  Treatment.insert
    value: "bestPrivate"
    showBestAns:   true
    showAvg:       false
    showChatRoom:  false
    showOtherAns:  false
    showSecondStage:   false
    pointsRule:        "ownAnswer"
#
#    value: "bestChat"
#    showBestAns:   true
#    showAvg:       false
#    showChatRoom:  true
#    showOtherAns:  false
#    showSecondStage:   false
#    pointsRule:        "ownAnswer"

#    value: "bestPublic"
#    showBestAns:   true
#    showAvg:       false
#    showChatRoom:  false
#    showOtherAns:  true
#    showSecondStage:   false
#    pointsRule:        "ownAnswer"

#    value: "bestPublicChat"
#    showBestAns:   true
#    showAvg:       false
#    showChatRoom:  true
#    showOtherAns:  true
#    showSecondStage:   false
#    pointsRule:        "ownAnswer"

#    value: "avgPrivate"
#    showBestAns:   false
#    showAvg:       true
#    showChatRoom:  false
#    showOtherAns:  false
#    showSecondStage:   false
#    pointsRule:        "average"

#    value: "avgChat"
#    showBestAns:   false
#    showAvg:       true
#    showChatRoom:  true
#    showOtherAns:  false
#    showSecondStage:   false
#    pointsRule:        "average"

#    value: "avgPublic"
#    showBestAns:   false
#    showAvg:       true
#    showChatRoom:  false
#    showOtherAns:  true
#    showSecondStage:   false
#    pointsRule:        "average"

#    value: "avgPublicChat"
#    showChatRoom:  true
#    showOtherAns:  true
#    showAvg:       true
#    showBestAns:   false
#    showSecondStage:   false
#    pointsRule:        "average"

#    value: "competitive-votebestanswer"
#    showChatRoom:  true
#    showOtherAns:  false
#    showAvg:       false
#    showBestAns:   true
#    showSecondStage:   true
#    secondStageType:   "voting"
#    pointsRule:        "ownAnswerByVotes"

#    value: "avgPublicChatbyvotes"
#    showChatRoom:  true
#    showOtherAns:  true
#    showAvg:       true
#    showBestAns:   false
#    showSecondStage:   true
#    secondStageType:   "voting"
#    pointsRule:        "averageByVotes"

#    value: "competitive-bettingbestanswer"
#    showChatRoom:  true
#    showOtherAns:  false
#    showAvg:       false
#    showBestAns:   true
#    showSecondStage:   true
#    secondStageType:   "betting"
#    pointsRule:        "ownAnswerByBets"

#    value: "avgPublicChatbybets"
#    showChatRoom:  true
#    showOtherAns:  false
#    showAvg:       true
#    showBestAns:   false
#    showSecondStage:   true
#    secondStageType:   "betting"
#    pointsRule:        "averageByBets"


  for user in Meteor.users.find().fetch()
    Meteor.users.update {username: user.username},
      $set: {rand: Math.random()}


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
#      $set: {start: false}

  else
    Timers.insert
      name: name
      endTime: time
      secondsLeft: timerMainDur
      start: true
#      start: false

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

  TutorialCounter.remove({})
  users = Meteor.users.find().fetch()
  for user in users
    TutorialCounter.insert
      userId: user._id
      index: 0

  TutorialData.remove({})
  users = Meteor.users.find().fetch()
  for user in users
    TutorialData.insert
      userId: user._id
      answers:
        [
          username: "alice"
          answer: null
          status: "pending"
        ,
          username: "carol"
          answer: 38
          status: "submitted"
        ,
          username: "bob"
          answer: 56
          status: "finalized"
        ]
      correctAnswer: 35



  TutorialText.remove({})
  TutorialText.insert
    type: "bestPrivate"
    text:
      0: "In this task, you will play 10 games with other MTurk workers.  In each game, you and other players will
          answer one question and get points based on your answers.  IMPORTANT: Please DO NOT use search engines
          or other resources to look up the answers to these questions.  This would defeat the purpose of this research
          project.  Rather, we hope you treat this as a game and just HAVE FUN."
      1: "Let's go through a game with 3 players (see the game interface below).  You can click UPDATE to submit or
          update your answer (shown in the red box), and click FINALIZE to confirm it. You cannot change a finalized answer.
          Your answer must be a valid number from 0 to 100 inclusive, and it will be automatically truncated
          to 2 decimal places.  Try it below."
      2: "During the game, you can see the status of the other players' answers (pending, submitted, finalized) in the
          yellow boxes, but NOT their answers.  Each game is limited to 1 minute. If the timer runs out before all
          answers are finalized, 50% is used for any missing answer and all answers are finalized automatically."
      3: "Once all answers are finalized or the timer runs out, the game ends.  Before the next game starts, there is
          a 10 seconds break and you can look at all players' answers, the correct answer, and the best
          answer(s) (closest to the correct answer).
          At any time, the table on the right shows the results of all previous games."
      4: "If your answer is one of the best answer(s), you get 100 points.  Otherwise, you get 10 points.  When all
          games are finished, the AVERAGE of your points from all games will be converted to
          your bonus payment (100 points = $1). This is the end of the tutorial.  Proceed to the quiz when you are ready."

  TutorialText.insert
    type: "avgPublicChat"
    text:
      0: "In this task, you will play 10 games with other MTurk workers.  In each game, you and other players will
          answer one question and get points based on your answers.  IMPORTANT: Please DO NOT use search engines
          or other resources to look up the answers to these questions.  This would defeat the purpose of this research
          project.  Rather, we hope you treat this as a game and just HAVE FUN."
      1: "Let's go through a game with 3 players (see the game interface below).  You can click UPDATE to submit or
          update your answer (shown in the red box), and click FINALIZE to confirm it. You cannot change a finalized answer.
          Your answer must be a valid number from 0 to 100 inclusive, and it will be automatically truncated
          to 2 decimal places.  Try it below."
      2: "During the game, every player's answer is revealed to all players as soon as it's submitted and whenever it's
          updated, and you can chat with other players in the chat room provided.
          Each game is limited to 1 minute. If the timer runs out before all answers are finalized, 50% is used for any
          missing answer and all answers are finalized automatically."
      3: "Once all answers are finalized or the timer runs out, the game ends.  Before the next game starts, there is
          a 10 second break and you can look at all players' answers and their average, and the correct answer.
          At any time, the table on the right shows the results of all previous games."
      4: "Every player gets the same number of points equal to the absolute difference between the average and the
          correct answer.
          When all games are finished, the AVERAGE of your points from all games will be converted to
          your bonus payment (100 points = $1). This is the end of the tutorial.  Proceed to the quiz when you are ready."




  ErrorMessages.remove({})
  QuizAttempts.remove({})

  PlayerStatus.remove({})
  users = Meteor.users.find().fetch()
  for user in users
    PlayerStatus.insert
      userId: user._id
      ready: false
































