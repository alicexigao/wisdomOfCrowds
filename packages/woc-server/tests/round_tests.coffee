groupId = "fakeGroup"

withCleanup = (func) ->
  return ->
    args = arguments
    Settings.remove({ _direct: true})
    Rounds.remove({ _direct: true })
    Meteor.flush()

    try
      res = TurkServer.bindGroup groupId, ->
        func.apply(this, args);
    catch error
      throw error
    finally

    return res

Tinytest.addAsync "server - rounds - single tick", withCleanup (test, next) ->

  unless Settings.findOne("blah")
    Settings.insert
      _id: "blah"
      answer: 4.57

  Rounds.insert
    index: 1
    questionId: "blah"
    active: true
    page: "task"
    startTime: Date.now()
    secondsLeft: 10

  timer = new TestObjects.RoundTimer(10)

  result = null
  Meteor.setTimeout (->
    timer.tick()
    result = Rounds.findOne()

    test.equal result.index, 1
    test.equal result.questionId, "blah"
    test.isTrue result.secondsLeft >= 9 and result.secondsLeft <= 10

    next()
  ), 1000



