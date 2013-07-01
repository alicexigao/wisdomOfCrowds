this.ChatMessages = new Meteor.Collection('chatMessages')

this.Answers = new Meteor.Collection('answers')

this.Rounds = new Meteor.Collection('rounds')

this.CurrentRound = new Meteor.Collection("currentRound")

this.Treatment = new Meteor.Collection('treatment')

this.TimeLeft = new Meteor.Collection("timeleft")

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
      answerDataId = Answers.update {userId: user._id},
        $set: {answer: data.answer}
        $set: {status: data.status}

    else

    # insert new answer
      answerData =
        userId: user._id
        answer: data.answer
        status: data.status
      answerDataId = Answers.insert answerData
    answerDataId

  countdown: (data) ->
    currTime = new Date()
    obj = TimeLeft.findOne()
    if obj
      endTime = new Date(obj.endTime)
      if currTime < endTime
        numSeconds = (endTime.getTime() - currTime.getTime()) / 1000
        numSeconds = Math.floor(numSeconds)
        TimeLeft.update {},
          $set: {secondsLeft: numSeconds}

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

  completeQuestion: (data) ->
    roundNum = CurrentRound.findOne().index
    Rounds.update {index: roundNum},
      $set: {status: "completed"}

  goToNextQuestion: (data) ->
    Answers.remove({})
    CurrentRound.update({}, {$inc: {index: 1}})

    time = new Date()
    endTime = time.getTime() + 1000 * 120
    time.setTime(endTime)
    TimeLeft.update {},
      $set: {endTime: time}
    TimeLeft.update {},
      $set: {secondsLeft: 120}