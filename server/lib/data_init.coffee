
shuffle = (sourceArray) ->
  n = 0
  while n < sourceArray.length - 1
    k = n + Math.floor(Math.random() * (sourceArray.length - n))
    temp = sourceArray[k]
    sourceArray[k] = sourceArray[n]
    sourceArray[n] = temp
    n++

Meteor.startup ->
  if Settings.find().count() is 0
    Settings.insert
      key: "taskQuestion"
      value: "What percent of the world's population lives in the U.S.? (U.S. Census Bureau, International Database, 6/2/2007)"
      answer: 4.57

    Settings.insert
      key: "taskQuestion"
      value: "What percent of U.S. households own at least one pet cat? (U.S. Pet Ownership & Demographics Sourcebook, 2002)"
      answer: 31.6

    Settings.insert
      key: "taskQuestion"
      value: "What percent of the world's population speaks Spanish as their first language? (Ethnologue: Languages of the World, 4/2007)"
      answer: 4.88

    Settings.insert
      key: "tutorialQuestion"
      value: "Fake Tutorial Question 1"
      answer: 30

    Settings.insert
      key: "tutorialQuestion"
      value: "Fake Tutorial Question 2"
      answer: 70

  # Static treatment data
  Treatment.remove({})
  Treatment.insert
    value: "bestPrivate"
    rewardRule:    "best"
    showChatRoom:  false
    showOtherAns:  false
    showBestAns:   true
    showAvg:       false
  Treatment.insert
    value: "bestPrivateChat"
    rewardRule:    "best"
    showChatRoom:  true
    showOtherAns:  false
    showBestAns:   true
    showAvg:       false
  Treatment.insert
    value: "bestPublic"
    rewardRule:    "best"
    showChatRoom:  false
    showOtherAns:  true
    showBestAns:   true
    showAvg:       false
  Treatment.insert
    value: "bestPublicChat"
    rewardRule:    "best"
    showChatRoom:  true
    showOtherAns:  true
    showBestAns:   true
    showAvg:       false
  Treatment.insert
    value: "avgPrivate"
    rewardRule:    "average"
    showBestAns:   false
    showAvg:       true
    showChatRoom:  false
    showOtherAns:  false
  Treatment.insert
    value: "avgPrivateChat"
    rewardRule:    "average"
    showChatRoom:  true
    showOtherAns:  false
    showBestAns:   false
    showAvg:       true
  Treatment.insert
    value: "avgPublic"
    rewardRule:    "average"
    showChatRoom:  false
    showOtherAns:  true
    showBestAns:   false
    showAvg:       true
  Treatment.insert
    value: "avgPublicChat"
    rewardRule:    "average"
    showChatRoom:  true
    showOtherAns:  true
    showAvg:       true
    showBestAns:   false

  # Users
  for user in Meteor.users.find().fetch()
    Meteor.users.update {username: user.username},
      $set: {rand: Math.random()}


  #  Answers.remove({})

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

  ErrorMessages.remove({})
  QuizAttempts.remove({})

  TurkServer.initialize ->
    @treatment
    # Do any experiment-specific operations here

    # Randomly order the questions for each treatment
    taskQuestions = Settings.find({key: "taskQuestion"}).fetch()
    #TODO: make sure randomization is working properly
    shuffle(taskQuestions)

    i = 0
    for question in taskQuestions
      active = false
      if i is 0
        active = true
      Rounds.insert
        index: i
        questionId: question._id
        active: active
        page: "task"
      i++

    tutorialQuestions = Settings.find({key: "tutorialQuestion"}).fetch()
    shuffle(tutorialQuestions)

    i = 0
    for question in tutorialQuestions
      active = false
      if i is 0
        active = true
      Rounds.insert
        index: i
        questionId: question._id
        active: active
        page: "tutorial"
      i++
















