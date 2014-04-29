Timers = {}

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

#    Settings.insert
#      key: "tutorialQuestion"
#      value: "Fake Tutorial Question 1"
#      answer: 30
#
#    Settings.insert
#      key: "tutorialQuestion"
#      value: "Fake Tutorial Question 2"
#      answer: 70

  # Static treatment data
  Treatment.remove({})
  Treatment.insert
    value: "bestPrivate"
    rewardRule: "best"
    showChatRoom: false
    showOtherAns: false
    showBestAns: true
    showAvg: false
  Treatment.insert
    value: "bestPrivateChat"
    rewardRule: "best"
    showChatRoom: true
    showOtherAns: false
    showBestAns: true
    showAvg: false
  Treatment.insert
    value: "bestPublic"
    rewardRule: "best"
    showChatRoom: false
    showOtherAns: true
    showBestAns: true
    showAvg: false
  Treatment.insert
    value: "bestPublicChat"
    rewardRule: "best"
    showChatRoom: true
    showOtherAns: true
    showBestAns: true
    showAvg: false
  Treatment.insert
    value: "avgPrivate"
    rewardRule: "average"
    showBestAns: false
    showAvg: true
    showChatRoom: false
    showOtherAns: false
  Treatment.insert
    value: "avgPrivateChat"
    rewardRule: "average"
    showChatRoom: true
    showOtherAns: false
    showBestAns: false
    showAvg: true
  Treatment.insert
    value: "avgPublic"
    rewardRule: "average"
    showChatRoom: false
    showOtherAns: true
    showBestAns: false
    showAvg: true
  Treatment.insert
    value: "avgPublicChat"
    rewardRule: "average"
    showChatRoom: true
    showOtherAns: true
    showAvg: true
    showBestAns: false

  QuizAttempts.remove({})
  ErrorMessages.remove({})

TurkServer.initialize ->
  groupId = @group
  @treatment
  # Do any experiment-specific operations here

  taskQuestions = Settings.find({key: "taskQuestion"}).fetch()
  shuffle(taskQuestions)

  # Round indices start from 1
  i = 1
  for question in taskQuestions
    Rounds.insert
      index: i
      questionId: question._id
    i++

#  tutorialQuestions = Settings.find({key: "tutorialQuestion"}).fetch()
#  shuffle(tutorialQuestions)
#
#  i = 0
#  for question in tutorialQuestions
#    active = false
#    if i is 0
#      active = true
#    Rounds.insert
#      index: i
#      questionId: question._id
#      active: active
#    i++

  # start first round
  startTime = Date.now()
  endTime = startTime + Timers.roundDur
  TurkServer.startNewRound(startTime, endTime, Timers.finalizeRound)

  return

# Schedule a new round if we're supposed to
Timers.finalizeRound = ->
  Timers.fakeAnswers()
  Timers.calcAvgAndBestAnswer()

  # return if we don't have any more rounds to go
  roundIndex = RoundTimers.findOne(active: true).index
  numQuestions = Rounds.find().count()
  return if roundIndex is numQuestions

  startTime = Date.now() + Timers.breakDur
  endTime = startTime + Timers.roundDur
  TurkServer.startNewRound(startTime, endTime, Timers.finalizeRound)

Timers.roundDur = 60000
Timers.breakDur = 10000

Timers.fakeAnswers = ->
#  console.log "fake answers called"

  roundIndex = RoundTimers.findOne(active: true).index
  users = Meteor.users.find().fetch()
  for user in users
    ans = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    if ans
      Answers.update
        roundIndex: roundIndex
        userId: user._id
      ,
        $set: {status: "finalized"}
    else
      answer = Math.floor(Math.random() * 100)
      Answers.insert
        roundIndex: roundIndex
        userId: user._id
        answer: answer
        status: "finalized"

Timers.calcAvgAndBestAnswer = ->
#  console.log "calculate avg and best answer called"

  roundIndex = RoundTimers.findOne(active: true).index
  #    console.log "current round " + roundIndex
  questionId = Rounds.findOne({active: true}).questionId
  questionObj = Settings.findOne({_id: questionId})
  correct = questionObj.answer
  #    console.log "correct answer " + correct

  users = Meteor.users.find().fetch()
  #    console.log users
  userIds = _.pluck(users, "_id")
  answers = Answers.find({roundIndex: roundIndex, userId:
    $in: userIds}).fetch()

  # calculte best answer
  bestAns = _.reduce answers, (currentBest, ansObj) ->
    if Math.abs(ansObj.answer - correct) < Math.abs(currentBest - correct) then ansObj.answer else currentBest
  , -Infinity
  #  console.log "best answer " + bestAns

  # list of user IDs who had the best answer
  bestAnsUserIds = _.pluck Answers.find({roundIndex: roundIndex, answer: bestAns}).fetch(), "userId"
  #  console.log "best ans user ids " + bestAnsUserIds


  # calculte average answer
  sumAns = _.reduce answers, (sum, ansObj) ->
    sum + ansObj.answer
  , 0
  avg = sumAns / answers.length
  #  console.log "average " + avg

  Rounds.update
    index: roundIndex
  , $set:
    "best": bestAns
    "average": avg
    "bestAnsUserIds": bestAnsUserIds