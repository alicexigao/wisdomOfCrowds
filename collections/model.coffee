
this.Settings = new Meteor.Collection('settings')
this.Treatment = new Meteor.Collection('treatment')

this.QuizAttempts = new Meteor.Collection('quizAttempts')
this.ErrorMessages = new Meteor.Collection('errorMessages')

this.PlayerStatus = new Meteor.Collection("playerStatus")

this.Timers = new Meteor.Collection("timeleft")

this.Rounds = new Meteor.Collection('rounds')

this.Answers = new Meteor.Collection('answers')
this.Votes = new Meteor.Collection('votes')
this.Bets = new Meteor.Collection('bets')

this.ChatMessages = new Meteor.Collection('chatMessages')

getRoundIndex = ->
  Settings.findOne({key: "roundIndex"}).value

getTreatment = ->
  Treatment.findOne()

getOnlineUsers = ->
  Meteor.users.find {"profile.online": true}

Meteor.methods
  sendMsg: (data) ->
    if (!Meteor.user())
      throw new Meteor.Error(401, "You need to login to chat")
    chatData =
      userId: Meteor.userId()
      username: Meteor.user().username
      timestamp: data.timestamp
      content: data.content
    ChatMessages.insert chatData



  countdownNext: (data) ->
    timerObj = Timers.findOne({name: "next"})
    return unless timerObj
    return unless timerObj.start is true

    currTime = new Date()
    endTime = new Date(timerObj.endTime)

    if currTime < endTime

      # Time is not up yet
      numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
      numSeconds = Math.floor(numSeconds)
      Timers.update {name: "next"},
        $set: {secondsLeft: numSeconds}

    else

      # Stop timer NEXT
      Timers.update {name: "next"},
        $set: {start: false}

      # incr round number
      Settings.update {key: "roundIndex"},
        $inc: {value: 1}

      # Reset and start main timer
      Meteor.call "startTimerFirst"

  startTimerFirst: ->
    timerFirstDur = 60
    time = new Date()
    endTime = time.getTime() + 1000 * timerFirstDur
    time.setTime(endTime)
    Timers.update {name: "main"},
      $set: {endTime: time}
    Timers.update {name: "main"},
      $set: {start: true}

  stopTimerFirst: ->
    Timers.update {name: "main"},
      $set: {start: false}

  countdownFirst: (data) ->
    timer = Timers.findOne({name: "main"})
    return unless timer
    return unless timer.start is true

    currTime = new Date()
    endTime = new Date(timer.endTime)

    if currTime < endTime

      # Time is not up yet
      numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
      numSeconds = Math.floor(numSeconds)
      Timers.update {name: "main"},
        $set: {secondsLeft: numSeconds}

    else

      # Stop timer first
      Timers.update {name: "main"},
        $set: {start: false}

      users = getOnlineUsers().fetch()
      # put in fake answer and finalize
      roundIndex = getRoundIndex()
      for user in users
        ans = Answers.findOne({roundIndex: roundIndex, userId: user._id})
        if ans
          Answers.update {roundIndex: roundIndex, userId: user._id},
            $set: {status: "finalized"}
        else
          Answers.insert
            roundIndex: roundIndex
            userId: user._id
            answer: 50
            status: "finalized"

      tre = getTreatment()
      if tre and tre.showSecondStage
        # Start timer second
        Meteor.call "startTimerSecond"
      else
        # round is completed
        Meteor.call 'markRoundCompleted'

  startTimerSecond: ->
    timerSecondDur = 60
    time = new Date()
    endTime = time.getTime() + 1000 * timerSecondDur
    time.setTime(endTime)
    Timers.update {name: "second"},
      $set: {endTime: time}
    Timers.update {name: "second"},
      $set: {start: true}

  stopTimerSecond: ->
    Timers.update {name: "second"},
      $set: {start: false}

  countdownSecond: (data) ->
    obj = Timers.findOne({name: "second"})
    return unless obj
    return unless obj.start is true

    if obj
      currTime = new Date()
      endTime = new Date(obj.endTime)
      if currTime < endTime

        # Time is not up yet
        numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
        numSeconds = Math.floor(numSeconds)
        Timers.update {name: "second"},
          $set: {secondsLeft: numSeconds}

      else

        # Stop this timer
        Timers.update {name: "second"},
          $set: {start: false}

        roundIndex = getRoundIndex()
        users = getOnlineUsers().fetch()
        tre = getTreatment()
        if tre and tre.showSecondStage and tre.secondStageType is "voting"

          # put in fake votes
          for user in users
            vote = Votes.findOne {roundIndex: roundIndex, userId: user._id}
            if vote
              Votes.update {roundIndex: roundIndex, userId: user._id},
                $set: {status: "finalized"}
            else
              Votes.insert
                roundIndex: roundIndex
                userId: user._id
                answerId: user._id
                status: "finalized"


        if tre and tre.showSecondStage and tre.secondStageType is "betting"

          # put in fake bets
          for user in users
            bets = Bets.find({roundIndex: roundIndex, userId: user._id}).fetch()
            if bets.length > 0
              Bets.update {roundIndex: roundIndex, userId: user._id},
                $set: {status: "finalized"}
            else
              Bets.insert
                roundIndex: roundIndex
                userId: user._id
                answerId: user._id
                amount: 1
                status: "finalized"

        Meteor.call 'markRoundCompleted'

  # do things when the round is completed
  markRoundCompleted: (data) ->
    roundIndex = getRoundIndex()
    round = Rounds.findOne {index: roundIndex}

    # if voting, calc num of votes and average by votes
    tre = getTreatment()
    if tre and tre.showSecondStage and tre.secondStageType is "voting"

      # calc average by votes
      numVotes = 0
      sumVotes = 0
      for user in Meteor.users().find().fetch()
        ans = Answers.findOne({roundIndex: roundIndex, userId: user._id}).answer
        votes = Votes.find({roundIndex: roundIndex, answerId: user._id}).count()
        sumVotes += ans * votes
        numVotes += votes
      avgByVotes = sumVotes / numVotes
      Rounds.update {index: roundIndex},
        $set: {averageByVotes: avgByVotes}

    if tre and tre.showSecondStage and tre.secondStageType is "betting"

      betsAndAnswers = 0
      bets = 0
      for user in Meteor.users().find().fetch()

        ans = Answers.findOne({roundIndex: roundIndex, userId: user._id}).answer
        betAmt = 0
        Bets.find({roundIndex: roundIndex, answerId: user._id}).forEach (record) ->
          betAmt += record.amount

        betsAndAnswers += ans * betAmt
        bets += betAmt
      avgByBets = betsAndAnswers / bets
      Rounds.update {index: roundIndex},
        $set: {averageByBets: avgByBets}

    # calc average and best answer
    correct = round.correctanswer
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

    bestAnsUserIds = []
    for user in getOnlineUsers().fetch()
      userId = user._id
      ans = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
      if ans is bestAns
        bestAnsUserIds.push userId

    avg = sumAns / numAns
    Rounds.update {index: roundIndex},
      $set: {"average": avg}
    Rounds.update {index: roundIndex},
      $set: {"bestAns": bestAns}
    Rounds.update {index: roundIndex},
      $set: {"bestAnsUserIds": bestAnsUserIds}

    # mark round as completed
    Rounds.update {index: roundIndex},
      $set: {status: "completed"}

    numQuestions = Rounds.find().count()
    round =  Rounds.findOne({index: numQuestions - 1})
    if round
      if round.status is "completed"

      else
        # Start timer NEXT
        timerNextDur = 10
        time = new Date()
        nextEndTime = time.getTime() + 1000 * timerNextDur
        time.setTime(nextEndTime)
        Timers.update {name: "next"},
          $set: {endTime: time}
        Timers.update {name: "next"},
          $set: {secondsLeft: timerNextDur}
        Timers.update {name: "next"},
          $set: {start: true}


  #############################
  # First stage functions
  #############################
  updateAnswer: (data) ->
    roundIndex = getRoundIndex()
    userId = Meteor.userId()

    ansExists = Answers.findOne
      roundIndex: roundIndex
      userId: Meteor.userId()

    if ansExists
      # already has answer for current user
      if ansExists.status is "finalized"
        throw new Meteor.Error(100, "Answer has been finalized")

      # update answer
      if data.answer
        Answers.update
          roundIndex: roundIndex
          userId: userId
        , $set:
            answer: data.answer

      # update status
      Answers.update
        userId: userId
        roundIndex: roundIndex
      , $set:
          status: data.status

    else
      # insert new answer
      Answers.insert
        roundIndex: roundIndex
        userId: userId
        answer: data.answer
        status: data.status


  #############################
  # Voting functions
  #############################
  updateVote: (data) ->
    roundIndex = getRoundIndex()
    userId = Meteor.userId()

    vote = Votes.findOne {roundIndex: roundIndex, userId: userId}
    if vote
      if vote.status is "finalized"
        # error if answer has been finalized
        throw new Meteor.Error(100, "Vote has been finalized")

      Votes.update {roundIndex: roundIndex, userId: userId},
        $set: {answerId: data.answerId}
      Votes.update {roundIndex: roundIndex, userId: userId},
        $set: {status: "submitted"}

    else

      Votes.insert
        roundIndex: roundIndex
        userId:   userId
        answerId: data.answerId
        status:   "submitted"


  finalizeVote: (data) ->
    roundIndex = getRoundIndex()
    Votes.update {roundIndex: roundIndex, userId: Meteor.userId()},
      $set: {status: "finalized"}

  #############################
  # Betting functions
  #############################
  addBet: (data) ->
    roundIndex = getRoundIndex()
    userId = Meteor.userId()

    bet = Bets.findOne {roundIndex: roundIndex, userId: userId, answerId: data.answerId}
    if bet
      if bet.status is "finalized"
        # error if bet has been finalized
        throw new Meteor.Error(100, "Bet has been finalized")
      Bets.update {roundIndex: roundIndex, userId: userId, answerId: data.answerId},
        $set: {status: "submitted"}
      Bets.update {roundIndex: roundIndex, userId: userId, answerId: data.answerId},
        $set: {amount: data.amount}
    else
      Bets.insert
        roundIndex: roundIndex
        userId:   userId
        answerId: data.answerId
        status:   "submitted"
        amount:   data.amount

  removeBet: (data) ->
    bet = Bets.findOne
      roundIndex: roundIndex
      userId:  Meteor.userId()
      answerId: data.answerId
    if bet
      Bets.remove
        roundIndex: roundIndex
        userId:  Meteor.userId()
        answerId: data.answerId

  updateBet: (data) ->
    bet = Bets.findOne
      roundIndex: roundIndex
      userId: Meteor.userId()
      answerId: data.answerId
    return unless bet
    newBet = parseInt(bet.amount) + parseInt(data.change)
    if newBet is 0
      Meteor.call 'removeBet', data
    else
      Bets.update {roundIndex: roundIndex, userId: Meteor.userId(), answerId: data.answerId},
        $inc: {amount: data.change}

  finalizeBet: (data) ->
    bets = Bets.find({roundIndex: roundIndex, userId: Meteor.userId()}).fetch()
    for bet in bets
      Bets.update {roundIndex: roundIndex, userId: Meteor.userId(), answerId: bet.answerId},
        $set: {status: "finalized"}



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


  setStatusReady: (data) ->
    PlayerStatus.update {userId: data.userId},
      $set: {ready: true}
    result = PlayerStatus.find({ready: true}).count() is getOnlineUsers().count()
    Meteor.call "startTimerFirst"
    return result


