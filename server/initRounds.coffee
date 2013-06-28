Meteor.startup ->
  if Treatment.find().count() is 0
    Treatment.insert
      value: "cooperative"

  Rounds.remove({})
  if Rounds.find().count() is 0
    Rounds.insert
      index: 0
      question: "Population of USA in 2006"
      correctanswer: 55
      answers: {}
      status: "inprogress"
    Rounds.insert
      index: 1
      question: "Population of USA in 2007"
      correctanswer: 40
      answers: {}
      status: "inprogress"
    Rounds.insert
      index: 2
      question: "Population of USA in 2008"
      correctanswer: 35
      answers: {}
      status: "inprogress"

  CurrentRound.remove({})
  if CurrentRound.find().count() is 0
    CurrentRound.insert index : 0
  else
    CurrentRound.update {},
      $set: {index: 0}
