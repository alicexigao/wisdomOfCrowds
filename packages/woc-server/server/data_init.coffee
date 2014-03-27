
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

  QuizAttempts.remove({})
  ErrorMessages.remove({})

class RoundTimer
  constructor: (@gameDur) ->

  tick: =>
    console.log "round tick called"

    startTimeString = Rounds.findOne({active: true, page: "task"})?.startTime
    console.log startTimeString
    return unless startTimeString
    startTime = new Date(startTimeString)

    endTimeGame = new Date()
    endTimeGame.setTime(startTime.getTime() + 1000 * @gameDur)

    currTime = new Date()

    endTimeString = Rounds.findOne({active: true, page: "task"})?.endTime

    if !endTimeString and currTime < endTimeGame

      if answersFinalized()
        console.log "round ends because all answers finalized"
        @endRound()
      else
        console.log "tick for round"
        @updateRemainingTime endTimeGame.getTime()

    else if !endTimeString and currTime >= endTimeGame
      console.log "round should have ended but no end time recorded"
      @endRound()

    else
      # endTimeString saved in round
      console.log "at break"

      endTimeBreak = new Date()
      endTimeBreak.setTime(new Date(endTimeString) + 1000 * @gameDur)

      if currTime < endTimeBreak
        console.log "tick for break"
        @updateRemainingTime endTimeBreak.getTime()
      else
        console.log "finish break"
        @finishBreak()

  updateRemainingTime: (timestamp) ->
    secondsLeft = Math.round( (timestamp - Date.now()) / 1000)
    console.log secondsLeft
    Rounds.update
      page: "task"
      active: true
    , $set:
      secondsLeft: secondsLeft

  finishBreak: ->
    # finish current round
    roundIndex = Rounds.findOne({active: true, page: "task"}).index
    Rounds.update
      page: "task"
      index: roundIndex
    , $set:
      active: false
    , (error, result) ->
      # start next round, with start time
      startTime = new Date()
      secondsLeft = 60
      Rounds.update
        index: roundIndex + 1
        page: "task"
      , $set:
        active: true
        startTime:   startTime
        secondsLeft: secondsLeft

  endRound: ->
    Rounds.update
      page: "task"
      active: true
    , $set:
      endTime: Date.now()

    # insert fake answers if necessary
    fakeAnswers()

    # calculate average and best answers
    calcAvgAndBestAnswer()

    # if this is the last round, stop ticking
    roundIndex = Rounds.findOne({active: true, page: "task" }).index
    numRounds = Rounds.find({page: "task"}).count()
    if roundIndex is numRounds - 1
      console.log "last round, stop ticking"
      Meteor.clearInterval(@intervalTimerId)
      @intervalTimerId = undefined

  setIntervalId: (id) ->
    @intervalTimerId = id

TestObjects.RoundTimer = RoundTimer

TurkServer.initialize ->
  groupId = @group
  @treatment
  # Do any experiment-specific operations here

  taskQuestions = Settings.find({key: "taskQuestion"}).fetch()
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

  gameDur = 10

  # set start time of first round
  startTime = new Date()
  secondsLeft = gameDur
  Rounds.update
    page: "task"
    active: true
  , $set:
    startTime:   startTime
    secondsLeft: secondsLeft

  timer = new RoundTimer(gameDur)
  intervalTimerId = Meteor.setInterval(timer.tick, 1000)
  timer.setIntervalId(intervalTimerId)

  return

answersFinalized = ->
  users = Meteor.users.find({"status.online": true}).fetch()
  roundIndex = Rounds.findOne({active: true})?.index
  for user in users
    ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    return false unless ansObj
    if ansObj.status isnt "finalized"
      return false
  # TODO: what to return when no user exists
  return false

fakeAnswers = ->
  console.log "fake answers called"

  roundIndex = Rounds.findOne({active: true, page: "task"}).index
  #    console.log roundIndex
  users = Meteor.users.find({"status.online": true}).fetch()
  console.log users
  for user in users
    ans = Answers.findOne({roundIndex: roundIndex, userId: user._id, page: "task"})
    if ans
      Answers.update
        roundIndex: roundIndex
        userId: user._id
        page: "task"
      ,
        $set: {status: "finalized"}
    else
      answer = Math.floor(Math.random()*100)
      Answers.insert
        roundIndex: roundIndex
        userId: user._id
        answer: answer
        status: "finalized"
        page: "task"

calcAvgAndBestAnswer = ->
  console.log "calculate avg and best answer called"

  page = "task"
  roundIndex = Rounds.findOne({active: true, page: page}).index
  #    console.log "current round " + roundIndex
  questionId = Rounds.findOne({active: true, page: page}).questionId
  questionObj = Settings.findOne({_id: questionId})
  correct = questionObj.answer
  #    console.log "correct answer " + correct
  numAns = 0
  sumAns = 0
  bestAns = -Infinity

  users = Meteor.users.find({"status.online": true}).fetch()
  #    console.log users
  for user in users
    ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    console.log ansObj
    ans = ansObj.answer
    sumAns += ans
    numAns++
    if Math.abs(ans - correct) < Math.abs(bestAns - correct)
      bestAns = ans
  #    console.log "best answer " + bestAns

  bestAnsUserIds = []
  for user in users
    ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    ans = ansObj.answer
    if ans is bestAns
      bestAnsUserIds.push user._id
  #    console.log "best ans user ids " + bestAnsUserIds

  avg = sumAns / numAns
  #    console.log "average " + avg

  Rounds.update
    index: roundIndex
    page: "task"
  , $set:
    "best": bestAns
    "average": avg
    "bestAnsUserIds": bestAnsUserIds