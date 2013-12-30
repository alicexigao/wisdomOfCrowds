
# get treatment
getTreatment = ->
  Treatment.findOne()

# get round index
getRoundIndex = ->
  # TODO: Is this every used for the tutorial?  Won't work for tutorial for now.
  Rounds.findOne({active: true, page: "task"}).index

# get online users
getOnlineUsers = ->
  Meteor.users.find {"status.online": true}

# if answer exists, finalize it
# else insert a finalized answer of 50
fakeAnswers = ->
  console.log "fake answers called"
  roundIndex = getRoundIndex()
  users = getOnlineUsers().fetch()
  for user in users
    ans = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    if ans
      Answers.update
        roundIndex: roundIndex
        userId: user._id
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

intervalIdFirst = undefined
intervalIdNext = undefined

calcAvgAndBestAnswer = (usersCursor) ->

  if Meteor.isServer

    roundIndex = getRoundIndex()
    questionId = Rounds.findOne({active: true}).questionId
    questionObj = Settings.findOne({_id: questionId})
    correct = questionObj.answer
    numAns = 0
    sumAns = 0
    bestAns = -Infinity

    for user in usersCursor.fetch()
      ansObj = Answers.findOne({roundIndex: roundIndex, userId: user._id})
      ans = ansObj.answer
      sumAns += ans
      numAns++
      if Math.abs(ans - correct) < Math.abs(bestAns - correct)
        bestAns = ans

    bestAnsUserIds = []
    for user in usersCursor.fetch()
      userId = user._id
      ans = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
      if ans is bestAns
        bestAnsUserIds.push userId

    avg = sumAns / numAns

    Rounds.update
      index: roundIndex
    , $set:
      "best": bestAns
      "average": avg
      "bestAnsUserIds": bestAnsUserIds


Meteor.methods

  calcRoundAverage: ->
    Rounds.update
      index: 0
    , $set:
      "average": 0.56

  countdownFirst: ->
    console.log "countdownFirst called"

    # decrement timer
    currTime = new Date()
    endTimeString = Timers.findOne({name: "first"}).endTime
    endTime = new Date(endTimeString)

    numSeconds = 0
    if currTime < endTime
      numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
      numSeconds = Math.round(numSeconds)
    Timers.update {name: "first"},
      $set: {secondsLeft: numSeconds}

    # if timer is done, end current round
    if numSeconds is 0
      fakeAnswers()
      Meteor.call 'endCurrRound'

  countdownNext: ->
    console.log "countdownNext called"

    # decrement timer
    currTime = new Date()
    endTimeString = Timers.findOne({name: "next"}).endTime
    endTime = new Date(endTimeString)

    numSeconds = 0
    if currTime < endTime
      numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
      numSeconds = Math.round(numSeconds)
    Timers.update {name: "next"},
      $set: {secondsLeft: numSeconds}

    # if timer is done, start next round
    if numSeconds is 0
      Meteor.call 'startNextRound', {}, (error, result) ->
        return result

#######################
# start next round
#######################
  startNextRound: ->
    console.log "startNextRound called"

    # stop timer next
    if intervalIdNext isnt undefined
      Meteor.clearInterval(intervalIdNext)
      intervalIdNext = undefined

    # if this is the last round, stop
    roundIndex = getRoundIndex()
    console.log "current round " + roundIndex
    numRounds = Rounds.find({page: "task"}).count()
    if roundIndex is numRounds - 1
      return

    # incr round index
    console.log "advance to next round"
    Rounds.update
      index: roundIndex
      page: "task"
    , $set:
      active: false
    , (error, result) ->
      Rounds.update
        index: roundIndex + 1
        page: "task"
      , $set:
        active: true

    # start timer first
    console.log "starting timer first"
    time = new Date()
    nextEndTime = time.getTime() + 1000 * 60
    time.setTime(nextEndTime)

    if Meteor.isServer
      Timers.update {name: "first"}
      , $set:
        endTime: time
        secondsLeft: 60
      , (error, result) ->
        if intervalIdFirst is undefined
          intervalIdFirst = Meteor.setInterval (->
            Meteor.call 'countdownFirst'
          ), 1000

####################
# end current round
####################
  endCurrRound: () ->
    console.log "endCurrRound called"

    users = getOnlineUsers()
    calcAvgAndBestAnswer(users)

    # stop timer first
    if intervalIdFirst isnt undefined
      Meteor.clearInterval(intervalIdFirst)
      intervalIdFirst = undefined

    # start timer next
    time = new Date()
    nextEndTime = time.getTime() + 1000 * 10
    time.setTime(nextEndTime)

    if Meteor.isServer

      Timers.update {name: "next"}
      , $set:
        endTime: time
        secondsLeft: 10
      , (error, result) ->
        if intervalIdNext is undefined
          intervalIdNext = Meteor.setInterval (->
            Meteor.call 'countdownNext'
          ), 1000

# save chat messages
  sendMsg: (data) ->
    if not Meteor.user()
      throw new Meteor.Error(401, "You need to login to chat")
    chatData =
      page      : data.page
      userId    : Meteor.userId()
      username  : Meteor.user().username
      timestamp : data.timestamp
      content   : data.content
    ChatMessages.insert chatData

# update of finalize answer
  updateAnswer: (data) ->
    ansExists = Answers.findOne
      roundIndex: data.roundIndex
      userId    : data.userId
      page      : data.page

    if ansExists
      # already has answer for current user
      if ansExists.status is "finalized"
        throw new Meteor.Error(100, "Answer has been finalized")

      # update answer
      if data.answer
        Answers.update
          roundIndex: data.roundIndex
          userId    : data.userId
        , $set:
          answer  : data.answer

      # update status
      Answers.update
        roundIndex: data.roundIndex
        userId    : data.userId
      , $set:
        status  : data.status
        page    : data.page

    else
      # insert new answer
      Answers.insert
        roundIndex: data.roundIndex
        userId    : data.userId
        answer    : data.answer
        status    : data.status
        page      : data.page


  clearTutorialCurrUserAnswer: (userId) ->
    Answers.remove({userId: userId, page: "tutorial"})

  # update tutorial answers
  updateTutorialAnswer: (data) ->
    ansObj = Answers.findOne({userId: data.userId, page: "tutorial"})
    unless ansObj
      console.log "ansObj does not exist, insert new answer"
      answer = Math.floor(Math.random()*100)
      Answers.insert
        roundIndex: 0
        userId    : data.userId
        answer    : answer
        status    : data.status
        page      : "tutorial"
    else if ansObj and not ansObj.answer
      console.log "answer does not exist, choose new answer and update"
      answer = Math.floor(Math.random()*100)
      Answers.update
        userId: data.userId
        page: "tutorial"
      , $set:
        answer: answer
        status: data.status
    else if ansObj and ansObj.answer
      console.log "answer exists, update status"
      Answers.update
        userId: data.userId
        page: "tutorial"
      , $set:
        status: data.status


#############################
# Quiz functions
#############################
  gradeQuiz: (data) ->

    if "q1" in data.list
      deduct = 0
    else
      deduct = 1
    total = 8
    QuizAttempts.insert
      userId: data.userId
      list:   data.list
      timestamp: new Date()
      score:  total - deduct
      total:  total

    numAttempts = QuizAttempts.find({userId: data.userId}).count()
    if ErrorMessages.findOne({userId: data.userId, type: "numAttempts"})
      ErrorMessages.update {userId: data.userId, type: "numAttempts"},
        $set: {numAttempts: numAttempts}
    else
      ErrorMessages.insert
        userId: data.userId
        type:   "numAttempts"
        numAttempts: numAttempts

    if deduct is 0
      ErrorMessages.remove({userId: data.userId, type: "quiz"})
      return true
    else
      msg = "Sorry, you've failed the quiz.  Please try again!"
      if ErrorMessages.findOne({userId: data.userId, type: "quiz"})
        ErrorMessages.update {userId: data.userId, type: "quiz"},
          $set: {message: msg}
      else
        ErrorMessages.insert
          userId: data.userId
          type    : "quiz"
          message : msg
      return false
