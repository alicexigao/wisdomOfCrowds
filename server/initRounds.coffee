Meteor.startup ->
  if Rounds.find().count() is 0
    Rounds.insert
      index: 0
      question: "Population of USA in 2006"
      correctanswer: 55
      answers: {}
    Rounds.insert
      index: 1
      question: "Population of USA in 2007"
      correctanswer: 40
      answers: {}
    Rounds.insert
      index: 2
      question: "Population of USA in 2008"
      correctanswer: 35
      answers: {}

  if CurrentRound.find().count() is 0
    CurrentRound.insert index : 0
  else
    CurrentRound.update {},
      $set: {index: 0}
