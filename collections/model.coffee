this.ChatMessages = new Meteor.Collection('chatMessages')

this.Answers = new Meteor.Collection('answers')

this.Rounds = new Meteor.Collection('rounds')

this.CurrentRound = new Meteor.Collection("currentRound")

this.Treatment = new Meteor.Collection('treatment')

this.Timers = new Meteor.Collection("timeleft")

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

  updateAnswer: (data) ->
    user = Meteor.user()
    if (!user)
      throw new Meteor.Error(401, "You need to login.")

    cur = Answers.find({userId: user._id})

    if cur.count() > 0
      # already has answer for current user

      if cur.fetch()[0].status is "finalized"
        # error if answer has been finalized
        throw new Meteor.Error(100, "Answer has been finalized")

      # update current answer
      if data.answer
        # takes care of case when user clicks on finalize without inputting a value
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
      answerDataId = Answers.insert answerData
    answerDataId

  countdownNext: (data) ->
    timerObj = Timers.findOne({name: "next"})
    return unless timerObj.start is true

    if timerObj
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

        # Go to next round
        Answers.remove({})
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

  stopTimerMain: (data) ->
    Timers.update {name: "main"},
      $set: {start: false}

  countdown: (data) ->
    obj = Timers.findOne({name: "main"})
    return unless obj.start is true

    if obj
      currTime = new Date()
      endTime = new Date(obj.endTime)
      if currTime < endTime

        # Time is not up yet
        numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
        numSeconds = Math.floor(numSeconds)
        Timers.update {name: "main"},
          $set: {secondsLeft: numSeconds}

      else

        # Time is up, complete this round
        users = Meteor.users.find().fetch()
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

        Meteor.call 'saveAnswers'
        Meteor.call 'markRoundCompleted'

  saveAnswers: (data) ->
    roundNum = CurrentRound.findOne().index
    ansArray = Answers.find().fetch()
    ansObj = {}
    for ansRecord in ansArray
      userId = ansRecord.userId
      ansObj[userId] = {}
      ansObj[userId].answer = ansRecord.answer
    Rounds.update {index: roundNum},
      $set: {answers: ansObj}

  markRoundCompleted: (data) ->
    roundNum = CurrentRound.findOne().index
    Rounds.update {index: roundNum},
      $set: {status: "completed"}

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

