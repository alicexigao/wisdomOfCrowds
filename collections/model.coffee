this.ChatMessages = new Meteor.Collection('chatMessages')

this.Answers = new Meteor.Collection('answers')

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

    if Answers.find({username: user.username}).count() > 0

      ansRecord = Answers.findOne({username: user.username})
      if ansRecord.finalized is true
        throw new Meteor.Error(100, "Answer has been finalized")

      answerDataId = Answers.update {username: user.username},
        $set: {answer: data.answer}
        $set: {submitted: true}
      answerDataId = Answers.update {username: user.username},
        $set: {finalized: data.finalized}
    else
      answerData =
        answer: data.answer
        userId: user._id
        username: user.username
        submitted: true
        finalized: data.finalized
      answerDataId = Answers.insert answerData
    answerDataId