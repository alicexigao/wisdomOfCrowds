Meteor.startup ->

  Settings.remove({})
  Settings.insert
    key: "roundIndex"
    value: 0

  Settings.insert
    key: "numGames"
    value: 10

  Treatment.remove({})
  Treatment.insert
    value: "bestPrivate"
    comm: "private"
    pay: "best"
    showBestAns:   true
    showAvg:       false
    showChatRoom:  false
    showOtherAns:  false
    showSecondStage:   false
    pointsRule:        "ownAnswer"
  Treatment.insert
    value: "bestChat"
    comm: "chat"
    pay: "best"
    showBestAns:   true
    showAvg:       false
    showChatRoom:  true
    showOtherAns:  false
    showSecondStage:   false
    pointsRule:        "ownAnswer"
  Treatment.insert
    value: "bestPublic"
    comm: "public"
    pay: "best"
    showBestAns:   true
    showAvg:       false
    showChatRoom:  false
    showOtherAns:  true
    showSecondStage:   false
    pointsRule:        "ownAnswer"
  Treatment.insert
    value: "bestPublicChat"
    comm: "publicChat"
    pay: "best"
    showBestAns:   true
    showAvg:       false
    showChatRoom:  true
    showOtherAns:  true
    showSecondStage:   false
    pointsRule:        "ownAnswer"
  Treatment.insert
    value: "avgPrivate"
    comm: "private"
    pay: "best"
    showBestAns:   false
    showAvg:       true
    showChatRoom:  false
    showOtherAns:  false
    showSecondStage:   false
    pointsRule:        "average"
  Treatment.insert
    value: "avgChat"
    comm: "chat"
    pay: "best"
    showBestAns:   false
    showAvg:       true
    showChatRoom:  true
    showOtherAns:  false
    showSecondStage:   false
    pointsRule:        "average"
  Treatment.insert
    value: "avgPublic"
    comm: "public"
    pay: "best"
    showBestAns:   false
    showAvg:       true
    showChatRoom:  false
    showOtherAns:  true
    showSecondStage:   false
    pointsRule:        "average"
  Treatment.insert
    value: "avgPublicChat"
    comm: "publicChat"
    pay: "best"
    showChatRoom:  true
    showOtherAns:  true
    showAvg:       true
    showBestAns:   false
    showSecondStage:   false
    pointsRule:        "average"


  for user in Meteor.users.find().fetch()
    Meteor.users.update {username: user.username},
      $set: {rand: Math.random()}


  Rounds.remove({})
  Rounds.insert
    index: 0
    question: "What percent of the world's population lives in the U.S.? (U.S. Census Bureau, International Database, 6/2/2007)"
    correctanswer: 4.57
    status: "inprogress"
    page: "task"
  Rounds.insert
    index: 1
    question: "What percent of U.S. households own at least one pet cat? (U.S. Pet Ownership & Demographics Sourcebook, 2002)"
    correctanswer: 31.6
    status: "inprogress"
    page: "task"
  Rounds.insert
    index: 2
    question: "What percent of the world's population speaks Spanish as their first language? (Ethnologue: Languages of the World, 4/2007)"
    correctanswer: 4.88
    status: "inprogress"
    page: "task"
  Rounds.insert
    index: 0
    question: "Fake Tutorial Question 1"
    correctanswer: 30
    status: "inprogress"
    page: "tutorial"
  Rounds.insert
    index: 1
    question: "Fake Tutorial Question 2"
    correctanswer: 70
    status: "inprogress"
    page: "tutorial"

  Answers.remove({})

  # Initialize timers
  Timers.remove({})

  name = "first"
  timerFirstDur = 60
  time = new Date()
  endTime = time.getTime() + 1000 * timerFirstDur
  time.setTime(endTime)
  Timers.insert
    name: name
    endTime: time
    secondsLeft: timerFirstDur
    start: true

  name = "next"
  timerNextDur = 10
  Timers.insert
    name: name
    secondsLeft: timerNextDur
    start: false

  ChatMessages.remove({})
  ErrorMessages.remove({})
  QuizAttempts.remove({})

#  PlayerStatus.remove({})
#  users = Meteor.users.find().fetch()
#  for user in users
#    PlayerStatus.insert
#      userId: user._id
#      ready: false































