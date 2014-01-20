
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

  intervalTimerId = null

  calcAvgAndBestAnswer = () ->
    console.log "calculate avg and best answer called"

    page = "task"
    roundIndex = Rounds.findOne({active: true, page: page, _groupId: groupId}).index
    #    console.log "current round " + roundIndex
    questionId = Rounds.findOne({active: true, page: page, _groupId: groupId}).questionId
    questionObj = Settings.findOne({_id: questionId})
    correct = questionObj.answer
    #    console.log "correct answer " + correct
    numAns = 0
    sumAns = 0
    bestAns = -Infinity

    users = Meteor.users.find({"status.online": true, admin: {$exists: false}}).fetch()
    #    console.log users
    for user in users
      ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id, _groupId: groupId})
      ans = ansObj.answer
      sumAns += ans
      numAns++
      if Math.abs(ans - correct) < Math.abs(bestAns - correct)
        bestAns = ans
    #    console.log "best answer " + bestAns

    bestAnsUserIds = []
    for user in users
      ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id, _groupId: groupId})
      ans = ansObj.answer
      if ans is bestAns
        bestAnsUserIds.push user._id
    #    console.log "best ans user ids " + bestAnsUserIds

    avg = sumAns / numAns
    #    console.log "average " + avg

    Rounds.update
      index: roundIndex
      _groupId: groupId
      page: "task"
    , $set:
      "best": bestAns
      "average": avg
      "bestAnsUserIds": bestAnsUserIds


  fakeAnswers = ->
    console.log "fake answers called"

    roundIndex = Rounds.findOne({_groupId: groupId, active: true, page: "task"}).index
#    console.log roundIndex
    users = Meteor.users.find({"status.online": true, admin: {$exists: false}}).fetch()
#    console.log users
    for user in users
      ans = Answers.findOne({_groupId: groupId, roundIndex: roundIndex, userId: user._id, page: "task"})
      if ans
        Answers.update
          _groupId: groupId
          roundIndex: roundIndex
          userId: user._id
          page: "task"
        ,
          $set: {status: "finalized"}
      else
        answer = Math.floor(Math.random()*100)
        Answers.insert
          _groupId: groupId
          roundIndex: roundIndex
          userId: user._id
          answer: answer
          status: "finalized"
          page: "task"

  gameDur = 10

  roundTick = ->
    console.log "round tick called"
    startTimeString = Rounds.findOne({active: true, page: "task", _groupId: groupId})?.startTime
    return unless startTimeString
    startTime = new Date(startTimeString)
    endTimeGame = new Date()
    endTimeGame.setTime(startTime.getTime() + 1000 * gameDur)

    currTime = new Date()

    endTimeString = Rounds.findOne({active: true, page: "task", _groupId: groupId})?.endTime

    if currTime >= endTimeGame or endTimeString
      console.log "at break"

      endTime = null
      if endTimeString
        endTime = new Date(endTimeString)
      else
        endTime = endTimeGame

      # save end time
      unless endTimeString
        Rounds.update
          _groupId: groupId
          page: "task"
          active: true
        , $set:
          endTime: endTime

      # tick for break
      endTimeBreak = new Date()
      endTimeBreak.setTime(endTime.getTime() + 1000 * 10)
      secondsLeft = Math.round((endTimeBreak.getTime() - currTime.getTime()) / 1000)
      console.log secondsLeft
      Rounds.update
        page: "task"
        active: true
        _groupId: groupId
      , $set:
        secondsLeft: secondsLeft

      # break is up
      if secondsLeft is 0
        console.log "break is up"
        roundIndex = Rounds.findOne({active: true, page: "task", _groupId: groupId}).index
        Rounds.update
          _groupId: groupId
          page: "task"
          index: roundIndex
        , $set:
          active: false

        startTime = new Date()
        secondsLeft = 60

        Rounds.update
          _groupId: groupId
          index: roundIndex + 1
          page: "task"
        , $set:
          active: true
          startTime:   startTime
          secondsLeft: secondsLeft

    else

      console.log "round in progress"
      secondsLeft = Math.round((endTimeGame.getTime() - currTime.getTime()) / 1000)
      console.log secondsLeft
      Rounds.update
        _groupId: groupId
        page: "task"
        active: true
      , $set:
        secondsLeft: secondsLeft

      # round is up
      if secondsLeft is 0
        console.log "round is up"
        # insert fake answers if necessary
        fakeAnswers()
        # calculate average and best answers
        calcAvgAndBestAnswer()

        # if this is the last round, stop ticking
        roundIndex = Rounds.findOne({active: true, page: "task", _groupId: groupId}).index
        numRounds = Rounds.find({page: "task"}).count()
        if roundIndex is numRounds - 1
          console.log "last round, stop ticking"
          Meteor.clearInterval(intervalTimerId)
          intervalTimerId = undefined

  intervalTimerId = Meteor.setInterval roundTick, 500
  return

# TODO: duplicate code here....
calcAvgAndBestAnswer = (groupId) ->
  console.log "calculate avg and best answer called"

  page = "task"
  roundIndex = Rounds.findOne({active: true, page: page, _groupId: groupId}).index
  #    console.log "current round " + roundIndex
  questionId = Rounds.findOne({active: true, page: page, _groupId: groupId}).questionId
  questionObj = Settings.findOne({_id: questionId})
  correct = questionObj.answer
  #    console.log "correct answer " + correct
  numAns = 0
  sumAns = 0
  bestAns = -Infinity

  users = Meteor.users.find({"status.online": true, admin: {$exists: false}}).fetch()
  #    console.log users
  for user in users
    ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id, _groupId: groupId})
    ans = ansObj.answer
    sumAns += ans
    numAns++
    if Math.abs(ans - correct) < Math.abs(bestAns - correct)
      bestAns = ans
  #    console.log "best answer " + bestAns

  bestAnsUserIds = []
  for user in users
    ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id, _groupId: groupId})
    ans = ansObj.answer
    if ans is bestAns
      bestAnsUserIds.push user._id
  #    console.log "best ans user ids " + bestAnsUserIds

  avg = sumAns / numAns
  #    console.log "average " + avg

  Rounds.update
    index: roundIndex
    _groupId: groupId
    page: "task"
  , $set:
    "best": bestAns
    "average": avg
    "bestAnsUserIds": bestAnsUserIds

Meteor.methods

  # when a round starts, save the start time
  saveStartTime: (groupId) ->
    if Meteor.isServer

      startTime = new Date()
      secondsLeft = 60

      Rounds.update
        _groupId: groupId
        page: "task"
        active: true
      , $set:
        startTime:   startTime
        secondsLeft: secondsLeft

  saveEndTime: (groupId) ->
    if Meteor.isServer
      endTime = new Date()
      Rounds.update
        _groupId: groupId
        page: "task"
        active: true
      , $set:
        endTime: endTime
      calcAvgAndBestAnswer(groupId)











