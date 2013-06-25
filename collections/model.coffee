this.ChatMessages = new Meteor.Collection('chatMessages')

this.Answers = new Meteor.Collection('answers')

this.Rounds = new Meteor.Collection('rounds')

this.CurrentRound = new Meteor.Collection("currentRound")

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

  saveAnswers: (data) ->
    roundNum = CurrentRound.findOne().index
    ansArray = Answers.find().fetch()
    Rounds.update({index: roundNum}, {$set: {answers: ansArray}})
    Answers.remove({})

  incrRoundNum: (data) ->
    CurrentRound.update({}, {$inc: {index: 1}})