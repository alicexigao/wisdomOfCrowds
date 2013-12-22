
this.Settings = new Meteor.Collection('settings')
this.Treatment = new Meteor.Collection('treatment')

this.QuizAttempts = new Meteor.Collection('quizAttempts')
this.ErrorMessages = new Meteor.Collection('errorMessages')

this.Rounds = new Meteor.Collection('rounds')
this.Answers = new Meteor.Collection('answers')
this.ChatMessages = new Meteor.Collection('chatMessages')
this.Timers = new Meteor.Collection("timeleft")

# get treatment
getTreatment = ->
  Treatment.findOne()

# get round index
getRoundIndex = ->
  Rounds.findOne({active: true}).index

# get online users
getOnlineUsers = ->
  Meteor.users.find {"profile.online": true}

# calculate average and best answer
calcAvgAndBestAnswer = ->
  roundIndex = getRoundIndex()
  questionId = Rounds.findOne({active: true}).questionId

  correct = Settings.findOne({_id: questionId}).answer
  numAns = 0
  sumAns = 0
  bestAns = -Infinity

  for user in getOnlineUsers().fetch()
    userId = user._id
    ans = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
    sumAns += ans
    numAns++
    if Math.abs(ans - correct) < Math.abs(bestAns - correct)
      bestAns = ans

  avg = sumAns / numAns

  bestAnsUserIds = []
  for user in getOnlineUsers().fetch()
    userId = user._id
    ans = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
    if ans is bestAns
      bestAnsUserIds.push userId

  Rounds.update
    index: roundIndex
  , $set:
      "best": bestAns
      "average": avg
      "bestAnsUserIds": bestAnsUserIds

# if answer exists, finalize it
# else insert a finalized answer of 50
fakeAnswers = ->
  console.log "fake answers called"
  roundIndex = getRoundIndex()
  users = getOnlineUsers().fetch()
  for user in users
    ans = Answers.findOne({roundIndex: roundIndex, userId: user._id})
    if ans
      console.log "finalize existing answer"
      Answers.update
        roundIndex: roundIndex
        userId: user._id
      ,
        $set: {status: "finalized"}
    else
      console.log "insert new answer 50"
      Answers.insert
        roundIndex: roundIndex
        userId: user._id
        answer: 50
        status: "finalized"
        page: "task"


intervalIdFirst = undefined
intervalIdNext = undefined


Meteor.methods

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
    numRounds = Rounds.find({page: "task"}).count()
    if roundIndex is numRounds - 1
      return

    # incr round index
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
  endCurrRound: ->
    console.log "endCurrRound called"

    calcAvgAndBestAnswer()

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
    if (!Meteor.user())
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


#  setStatusReady: (data) ->
#    PlayerStatus.update {userId: data.userId},
#      $set: {ready: true}
#    result = PlayerStatus.find({ready: true}).count() is getOnlineUsers().count()
#    Meteor.call "startTimerFirst"
#    return result


