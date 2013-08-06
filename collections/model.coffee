
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
      Answers.remove({})
      Votes.remove({})
      Bets.remove({})

      # incr round number
      CurrentRound.update({}, {$inc: {index: 1}})

      # Reset and start main timer
      timerMainDur = 60
      time = new Date()
      mainEndTime = time.getTime() + 1000 * timerMainDur
      time.setTime(mainEndTime)
      Timers.update {name: "main"},
        $set: {endTime: time}
      Timers.update {name: "main"},
        $set: {secondsLeft: timerMainDur}
      Timers.update {name: "main"},
        $set: {start: true}

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
      for user in users
        ans = Answers.findOne({userId: user._id})
        if ans
          Answers.update {userId: user._id},
            $set: {status: "finalized"}
        else
          Answers.insert
            userId: user._id
            answer: 50
            status: "finalized"
      # save all answers
      Meteor.call 'saveAllAnswers'

      tre = Treatment.findOne()
      if tre and tre.displaySecondStage and tre.secondStageType is "voting"
        # Start timer second
        Meteor.call "startTimerSecond"
      else if tre and tre.displaySecondStage and tre.secondStageType is "betting"
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

        users = Meteor.users.find().fetch()
        tre = Treatment.findOne()
        if tre and tre.displaySecondStage and tre.secondStageType is "voting"

          # put in fake votes
          for user in users
            vote = Votes.findOne {userId: user._id}
            if vote
              Votes.update {userId: user._id},
                $set: {status: "finalized"}
            else
              Votes.insert
                userId: user._id
                answerId: user._id
                status: "finalized"
          # save all votes
          Meteor.call 'saveAllVotes'

        if tre and tre.displaySecondStage and tre.secondStageType is "betting"

          # put in fake bets
          for user in users
            bets = Bets.find({userId: user._id}).fetch()
            if bets.length > 0
              Bets.update {userId: user._id},
                $set: {status: "finalized"}
            else
              Bets.insert
                userId: user._id
                answerId: user._id
                amount: 1
                status: "finalized"

          # save all bets
          Meteor.call 'saveAllBets'

        Meteor.call 'markRoundCompleted'

  # do things when the round is completed
  markRoundCompleted: (data) ->
    roundNum = CurrentRound.findOne().index
    round = Rounds.findOne {index: roundNum}

    # if voting, calc num of votes and average by votes
    tre = Treatment.findOne()
    if tre and tre.displaySecondStage and tre.secondStageType is "voting"

      # calc num of votes
      voteObj = round.votes
      for userId in Object.keys(voteObj)
        voteObj[userId].numVotes = 0
      for userId in Object.keys(voteObj)
        voted = round.votes[userId].vote
        numVotes = voteObj[voted].numVotes
        numVotes++
        voteObj[voted].numVotes = numVotes
      Rounds.update {index: roundNum},
        $set: {votes: voteObj}

      # calc average by votes
      numVotes = 0
      sumVotes = 0
      for userId in Object.keys(round.answers)
        ans = parseInt(round.answers[userId].answer)
        votes = round.votes[userId].numVotes
        sumVotes += ans * votes
        numVotes += votes
      Rounds.update {index: roundNum},
        $set: {averageByVotes: sumVotes / numVotes}

    if tre and tre.displaySecondStage and tre.secondStageType is "betting"

      # calc total bet amounts
      betAmt = {}
      for user in Meteor.users.find().fetch()
          betAmt[user._id] = {totalAmount: 0}

      betObj = round.bets
      for userId in Object.keys(betObj)
        for answerUserId in Object.keys(betObj[userId])
          amount = betObj[userId][answerUserId].amount
          betAmt[answerUserId].totalAmount += amount

      Rounds.update {index: roundNum},
        $set: {betAmounts: betAmt}

      # calc average by bets
      round = Rounds.findOne {index: roundNum}

      betsAndAnswers = 0
      bets = 0
      for userId in Object.keys(round.answers)

        ans = parseInt(round.answers[userId].answer)
        amt = round.betAmounts[userId].totalAmount

        betsAndAnswers += ans * amt
        bets += amt
      Rounds.update {index: roundNum},
        $set: {averageByBets: betsAndAnswers / bets}


    # calc average and winner
    correct = round.correctanswer
    numAns = 0
    sumAns = 0
    winnerAnswer = -Infinity
    for userId in Object.keys(round.answers)
      ans = parseInt(round.answers[userId].answer)
      sumAns += ans
      numAns++
      if Math.abs(ans - correct) < Math.abs(winnerAnswer - correct)
        winnerAnswer = ans

    winnerIdArray = []
    for userId in Object.keys(round.answers)
      ans = parseInt(round.answers[userId].answer)
      if ans is winnerAnswer
        winnerIdArray.push userId

    Rounds.update {index: roundNum},
      $set: {average: sumAns / numAns}

    Rounds.update {index: roundNum},
      $set: {winner: winnerAnswer}
    Rounds.update {index: roundNum},
      $set: {winnerIdArray: winnerIdArray}


    # mark round as completed
    Rounds.update {index: roundNum},
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
    user = Meteor.user()
    if (!user)
      throw new Meteor.Error(401, "You need to login.")

    cur = Answers.findOne {userId: user._id}
    if cur
      # already has answer for current user
      if cur.status is "finalized"
        # error if answer has been finalized
        throw new Meteor.Error(100, "Answer has been finalized")

      if data.answer isnt null
        # update current answer if
        Answers.update {userId: user._id},
          $set: {answer: data.answer}

      Answers.update {userId: user._id},
        $set: {status: data.status}

    else
      # insert new answer
      answerData =
        userId: user._id
        answer: data.answer
        status: data.status
      Answers.insert answerData

    if data.status is "finalized"
      Meteor.call "saveAnswer", data

  # save answers for a particular user
  saveAnswer: (data) ->
    roundNum = CurrentRound.findOne().index
    ansData = Answers.findOne({userId: data.userId})

    ansObj = Rounds.findOne({index: roundNum}).answers
    ansObj[data.userId] = {answer: ansData.answer}

    Rounds.update {index: roundNum},
      $set: {answers: ansObj}

  saveAllAnswers: ->
    ansObj = {}
    users = Meteor.users.find().fetch()
    for user in users
      ansRecord = Answers.findOne {userId: user._id}
      ansObj[user._id] = {answer: ansRecord.answer}

    roundNum = CurrentRound.findOne().index
    Rounds.update {index: roundNum},
      $set: {answers: ansObj}


  #############################
  # Voting functions
  #############################
  updateVote: (data) ->
    vote = Votes.findOne {userId: data.userId}
    if vote
      if vote.status is "finalized"
        # error if answer has been finalized
        throw new Meteor.Error(100, "Vote has been finalized")

      Votes.update {userId: data.userId},
        $set: {answerId: data.answerId}
      Votes.update {userId: data.userId},
        $set: {status: "submitted"}

    else

      Votes.insert
        userId:   data.userId
        answerId: data.answerId
        status:   "submitted"

  finalizeVote: (data) ->
    Votes.update {userId: data.userId},
      $set: {status: "finalized"}

    Meteor.call 'saveVote', data

  saveVote: (data) ->
    roundNum = CurrentRound.findOne().index
    voteData = Votes.findOne({userId: data.userId})

    voteObj = Rounds.findOne({index: roundNum}).votes
    voteObj[data.userId] = {vote: voteData.answerId}

    Rounds.update {index: roundNum},
      $set: {votes: voteObj}

  saveAllVotes: ->
    voteObj = {}
    users = Meteor.users.find().fetch()
    for user in users
      voteData = Votes.findOne({userId: user._id})
      voteObj[user._id] =
        vote: voteData.answerId
        numVotes: 1

    roundNum = CurrentRound.findOne().index
    Rounds.update {index: roundNum},
      $set: {votes: voteObj}


  #############################
  # Betting functions
  #############################
  addBet: (data) ->
    bet = Bets.findOne {userId: data.userId, answerId: data.answerId}
    if bet
      if bet.status is "finalized"
        # error if bet has been finalized
        throw new Meteor.Error(100, "Bet has been finalized")
      Bets.update {userId: data.userId, answerId: data.answerId},
        $set: {status: "submitted"}
      Bets.update {userId: data.userId, answerId: data.answerId},
        $set: {amount: data.amount}
    else
      Bets.insert
        userId:   data.userId
        answerId: data.answerId
        status:   "submitted"
        amount:   data.amount

  removeBet: (data) ->
    bet = Bets.findOne {userId: data.userId, answerId: data.answerId}
    if bet
      Bets.remove({userId: data.userId, answerId: data.answerId})

  updateBet: (data) ->
    bet = Bets.findOne {userId: data.userId, answerId: data.answerId}
    return unless bet
    newBet = parseInt(bet.amount) + parseInt(data.change)
    if newBet is 0
      Meteor.call 'removeBet', data
    else
      Bets.update {userId: data.userId, answerId: data.answerId},
        $inc: {amount: data.change}

  finalizeBet: (data) ->
    bets = Bets.find({userId: data.userId}).fetch()
    for bet in bets
      Bets.update {userId: data.userId, answerId: bet.answerId},
        $set: {status: "finalized"}

    Meteor.call 'saveBet', data

  saveBet: (data) ->
    roundNum = CurrentRound.findOne().index
    betObj = Rounds.findOne({index: roundNum}).bets
    betObj[data.userId] = {}

    betData = Bets.find({userId: data.userId}).fetch()
    for bet in betData
      betObj[data.userId][bet.answerId] = {amount: bet.amount}

    Rounds.update {index: roundNum},
      $set: {bets: betObj}

  saveAllBets: ->
    betObj = {}
    users = Meteor.users.find().fetch()
    for user in users
      betData = Bets.find({userId: user._id}).fetch()
      for bet in betData
        betObj[user._id] = {}
        betObj[user._id][bet.answerId] = {amount: bet.amount}

    roundNum = CurrentRound.findOne().index
    Rounds.update {index: roundNum},
      $set: {bets: betObj}



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
    if tre.displayWinner
      tutObj = TutorialData.findOne({userId: data.userId})
      correct = tutObj.correctAnswer
      bestAnswer = -Infinity
      for ansObj in tutObj.answers
        if Math.abs(ansObj.answer - correct) < Math.abs(bestAnswer - correct)
          bestAnswer = ansObj.answer
      TutorialData.update {userId: data.userId},
        $set: {winner: bestAnswer}

    if tre.displayAverage
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


