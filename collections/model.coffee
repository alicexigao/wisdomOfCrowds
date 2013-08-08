
this.Treatment = new Meteor.Collection('treatment')

this.TutorialCounter = new Meteor.Collection("tutorialCounter")
this.TutorialText = new Meteor.Collection("tutorialText")
this.TutorialData = new Meteor.Collection("tutorialData")

this.QuizAttempts = new Meteor.Collection('quizAttempts')
this.ErrorMessages = new Meteor.Collection('errorMessages')

this.PlayerStatus = new Meteor.Collection("playerStatus")

this.Timers = new Meteor.Collection("timeleft")

this.CurrentRound = new Meteor.Collection("currentRound")
this.Rounds = new Meteor.Collection('rounds')
this.Answers = new Meteor.Collection('answers')
this.Votes = new Meteor.Collection('votes')
this.Bets = new Meteor.Collection('bets')

this.ChatMessages = new Meteor.Collection('chatMessages')



Meteor.methods
  sendMsg: (data) ->
    user = Meteor.user()
    if (!user)
      throw new Meteor.Error(401, "You need to login to chat")

    chatData = _.extend(_.pick(data, 'author', 'timestamp', 'content'),
      userId: user._id
    )
    chatDataId = ChatMessages.insert chatData
    chatDataId

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

      # reset temporary objects
#      Answers.remove({})
#      Votes.remove({})
      Bets.remove({})

      # incr round number
      CurrentRound.update({}, {$inc: {index: 1}})

      # Reset and start main timer
      Meteor.call "startTimerMain"

  startTimerMain: ->
    timerMainDur = 60
    time = new Date()
    endTime = time.getTime() + 1000 * timerMainDur
    time.setTime(endTime)
    Timers.update {name: "main"},
      $set: {endTime: time}
    Timers.update {name: "main"},
      $set: {start: true}

  stopTimerMain: ->
    Timers.update {name: "main"},
      $set: {start: false}

  countdownMain: (data) ->
    obj = Timers.findOne({name: "main"})
    return unless obj
    return unless obj.start is true

    currTime = new Date()
    endTime = new Date(obj.endTime)

    if currTime < endTime

      # Time is not up yet
      numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
      numSeconds = Math.floor(numSeconds)
      Timers.update {name: "main"},
        $set: {secondsLeft: numSeconds}

    else

      # Stop this timer
      Timers.update {name: "main"},
        $set: {start: false}

      users = Meteor.users.find().fetch()
      # put in fake answer
      roundIndex = CurrentRound.findOne().index
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
      # save all answers
#      Meteor.call 'saveAllAnswers'

      tre = Treatment.findOne()
      if tre and tre.showSecondStage
        # Start timer second
        Meteor.call "startTimerSecond"
      else
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

        roundIndex = CurrentRound.findOne().index
        users = Meteor.users.find().fetch()
        tre = Treatment.findOne()
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
          # save all votes
#          Meteor.call 'saveAllVotes'

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

          # save all bets
#          Meteor.call 'saveAllBets'

        Meteor.call 'markRoundCompleted'

  # do things when the round is completed
  markRoundCompleted: (data) ->
    roundIndex = CurrentRound.findOne().index
    round = Rounds.findOne {index: roundIndex}

    # if voting, calc num of votes and average by votes
    tre = Treatment.findOne()
    if tre and tre.showSecondStage and tre.secondStageType is "voting"

      # calc num of votes
      voteObj = round.votes
      for userId in Object.keys(voteObj)
        voteObj[userId].numVotes = 0
      for userId in Object.keys(voteObj)
        voted = round.votes[userId].vote
        numVotes = voteObj[voted].numVotes
        numVotes++
        voteObj[voted].numVotes = numVotes
      Rounds.update {index: roundIndex},
        $set: {votes: voteObj}

      # calc average by votes
      numVotes = 0
      sumVotes = 0
      for userId in Object.keys(round.answers)

        ans = parseInt(Answers.findOne({roundIndex: roundIndex, userId: userId}))
        votes = round.votes[userId].numVotes
        sumVotes += ans * votes
        numVotes += votes
      Rounds.update {index: roundIndex},
        $set: {averageByVotes: sumVotes / numVotes}

    if tre and tre.showSecondStage and tre.secondStageType is "betting"

      # calc total bet amounts
      betAmt = {}
      for user in Meteor.users.find().fetch()
          betAmt[user._id] = {totalAmount: 0}

      betObj = round.bets
      for userId in Object.keys(betObj)
        for answerUserId in Object.keys(betObj[userId])
          amount = betObj[userId][answerUserId].amount
          betAmt[answerUserId].totalAmount += amount

      Rounds.update {index: roundIndex},
        $set: {betAmounts: betAmt}

      # calc average by bets
      round = Rounds.findOne {index: roundIndex}

      betsAndAnswers = 0
      bets = 0
      for userId in Object.keys(round.answers)

        ans = parseInt(Answers.findOne({roundIndex: roundIndex, userId: userId}))
        amt = round.betAmounts[userId].totalAmount

        betsAndAnswers += ans * amt
        bets += amt
      Rounds.update {index: roundIndex},
        $set: {averageByBets: betsAndAnswers / bets}


    # calc average and winner
    correct = round.correctanswer
    numAns = 0
    sumAns = 0
    bestAns = -Infinity

    users = Meteor.users.find().fetch()
    for user in users
      userId = user._id
      ansObj = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
      ans = parseInt(ansObj, 10)
      sumAns += ans
      numAns++
      if Math.abs(ans - correct) < Math.abs(bestAns - correct)
        bestAns = ans

    bestAnsUserids = []
    for user in users
      userId = user._id
      ansObj = Answers.findOne({roundIndex: roundIndex, userId: userId}).answer
      ans = parseInt(ansObj, 10)
      if ans is bestAns
        bestAnsUserids.push userId


    avg = sumAns / numAns
    Rounds.update {index: roundIndex},
      $set: {average: avg}

    Rounds.update {index: roundIndex},
      $set: {winner: bestAns}
    Rounds.update {index: roundIndex},
      $set: {winnerIdArray: bestAnsUserids}


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
    roundIndex = CurrentRound.findOne().index
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

#    if data.status is "finalized"
#      Meteor.call "saveAnswer", data

  # save answers for a particular user
#  saveAnswer: (data) ->
#    roundIndex = CurrentRound.findOne().index
#    ansData = Answers.findOne({userId: data.userId})
#
#    ansObj = Rounds.findOne({index: roundIndex}).answers
#    ansObj[data.userId] = {answer: ansData.answer}
#
#    Rounds.update {index: roundIndex},
#      $set: {answers: ansObj}
#
#  saveAllAnswers: ->
#    ansObj = {}
#    users = Meteor.users.find().fetch()
#    for user in users
#      ansRecord = Answers.findOne {userId: user._id}
#      ansObj[user._id] = {answer: ansRecord.answer}
#
#    roundNum = CurrentRound.findOne().index
#    Rounds.update {index: roundNum},
#      $set: {answers: ansObj}


  #############################
  # Voting functions
  #############################
  updateVote: (data) ->
    roundIndex = CurrentRound.findOne().index
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
    roundIndex = CurrentRound.findOne().index
    Votes.update {roundIndex: roundIndex, userId: Meteor.userId()},
      $set: {status: "finalized"}

  #############################
  # Betting functions
  #############################
  addBet: (data) ->
    roundIndex = CurrentRound.findOne().index
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
  # Tutorial functions
  #############################
  incrTutorialPage: (data) ->
    TutorialCounter.update {userId: data.userId},
      $inc: {index: data.change}

  tutorialUpdateAnswer: (data) ->
    tre = Treatment.findOne()
    return null unless tre

    if data.answer isnt null
      ansObj = TutorialData.findOne({userId: data.userId}).answers
      ansObj[0].answer = data.answer
      ansObj[0].status = data.status
      TutorialData.update {userId: data.userId},
        $set: {answers: ansObj}
    else
      ansObj = TutorialData.findOne({userId: data.userId}).answers
      ansObj[0].status = data.status
      TutorialData.update {userId: data.userId},
        $set: {answers: ansObj}

  finalizeAliceAnswer: (data) ->
    tre = Treatment.findOne()
    return null unless tre

    ansObj =  TutorialData.findOne({userId: data.userId}).answers
    if ansObj[0].answer is null
      ansObj[0].answer = 50
    ansObj[0].status = "finalized"

    TutorialData.update {userId: data.userId},
      $set: {answers: ansObj}

    # update winning answer
    if tre.showBestAns
      tutObj = TutorialData.findOne({userId: data.userId})
      correct = tutObj.correctAnswer
      bestAnswer = -Infinity
      for ansObj in tutObj.answers
        if Math.abs(ansObj.answer - correct) < Math.abs(bestAnswer - correct)
          bestAnswer = ansObj.answer
      TutorialData.update {userId: data.userId},
        $set: {winner: bestAnswer}

    if tre.showAvg
      tutObj = TutorialData.findOne({userId: data.userId})
      total = 0
      average = 0
      for ansObj in tutObj.answers
        total += ansObj.answer
      average = total / Object.keys(tutObj.answers).length
      TutorialData.update {userId: data.userId},
        $set: {average: average}

  clearAliceAnswer: (data) ->
    tre = Treatment.findOne()
    return null unless tre

    ansObj =  TutorialData.findOne({userId: data.userId}).answers
    ansObj[0].answer = null
    ansObj[0].status = "pending"

    TutorialData.update {userId: data.userId},
      $set: {answers: ansObj}
    TutorialData.update {userId: data.userId},
      $set: {winner: null}


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
    result = PlayerStatus.find({ready: true}).count() is Meteor.users.find().count()
    Meteor.call "startTimerMain"
    return result


