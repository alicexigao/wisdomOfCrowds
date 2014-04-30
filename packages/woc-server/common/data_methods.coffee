answersFinalized = ->
  # TODO: how to check only users in the same group as the current user?
  users = _.pluck Meteor.users.find().fetch(), "_id"
  round = RoundTimers.findOne(active: true)
  return _.every Answers.findOne({roundIndex: round.index, userId: $in: users}), (ansObj) ->
    ansObj?.status is "finalized"

Meteor.methods

  updateAnswer: (data) ->
    # update or finalize answer
    ansExists = Answers.findOne
      roundIndex: data.roundIndex
      userId: data.userId

    if ansExists
      # already has answer for current user
      if ansExists.status is "finalized"
        throw new Meteor.Error(100, "Answer has been finalized")

      # update answer
      if data.answer
        Answers.update
          roundIndex: data.roundIndex
          userId: data.userId
        , $set:
          answer: data.answer

      # update status
      Answers.update
        roundIndex: data.roundIndex
        userId: data.userId
      , $set:
        status: data.status

    else
      # insert new answer
      Answers.insert
        roundIndex: data.roundIndex
        userId: data.userId
        answer: data.answer
        status: data.status

    if Meteor.isServer and answersFinalized()
      # all answers are finalized before time limit is reached
      TurkServer.Timers.endCurrentRound()
      Timers.finalizeRound()
      return

  sendMsg: (data) ->
    # save chat messages
    if not Meteor.user()
      throw new Meteor.Error(401, "You need to login to chat")
    chatData =
      userId: Meteor.userId()
      username: Meteor.user().username
      timestamp: data.timestamp
      content: data.content
    ChatMessages.insert chatData

###########################
# Tutorial methods
###########################
  updateTutorialStatus: (data) ->
    ansObj = Answers.findOne({userId: data.userId})
    if ansObj
      Answers.update
        userId: data.userId
      , $set:
        status: data.status

  calcAvgAndBest: (users) ->
    calcAvgAndBestAnswer(users, "tutorial")

# update tutorial answers
  updateTutorialAnswer: (data) ->
    ansObj = Answers.findOne({userId: data.userId})
    if ansObj
#      console.log "answer exists, update status"
      Answers.update
        userId: data.userId
      , $set:
        status: data.status
    else if data.createAnswer is true
#        console.log "answer does not exist"
      Answers.insert
        roundIndex: 0
        userId: data.userId
        answer: Math.floor(Math.random() * 100)
        status: data.status

#############################
# Quiz functions
#############################
#  gradeQuiz: (data) ->
#
#    if "q1" in data.list
#      deduct = 0
#    else
#      deduct = 1
#    total = 8
#    QuizAttempts.insert
#      userId: data.userId
#      list:   data.list
#      timestamp: new Date()
#      score:  total - deduct
#      total:  total
#
#    numAttempts = QuizAttempts.find({userId: data.userId}).count()
#    if ErrorMessages.findOne({userId: data.userId, type: "numAttempts"})
#      ErrorMessages.update {userId: data.userId, type: "numAttempts"},
#        $set: {numAttempts: numAttempts}
#    else
#      ErrorMessages.insert
#        userId: data.userId
#        type:   "numAttempts"
#        numAttempts: numAttempts
#
#    if deduct is 0
#      ErrorMessages.remove({userId: data.userId, type: "quiz"})
#      return true
#    else
#      msg = "Sorry, you've failed the quiz.  Please try again!"
#      if ErrorMessages.findOne({userId: data.userId, type: "quiz"})
#        ErrorMessages.update {userId: data.userId, type: "quiz"},
#          $set: {message: msg}
#      else
#        ErrorMessages.insert
#          userId: data.userId
#          type    : "quiz"
#          message : msg
#      return false
