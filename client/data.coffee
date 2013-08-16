this.Tutorial = new Meteor.Collection(null)
this.TutorialRounds = new Meteor.Collection(null)
this.TutorialUsers = new Meteor.Collection(null)
this.TutorialAnswers = new Meteor.Collection(null)
this.TutorialChat = new Meteor.Collection(null)

Meteor.startup ->
  Session.set("tutorialIndex", 0)
  Session.set("tutorialRoundIndex", 0)

  TutorialRounds.remove({})
  TutorialRounds.insert
    index: 0
    question: "What percent of the world's population lives in the U.S.? (U.S. Census Bureau, International Database, 6/2/2007)"
    summary: "US population 2007"
    correctanswer: 4.57
    status: "inprogress"
  TutorialRounds.insert
    index: 1
    question: "What percent of U.S. households own at least one pet cat? (U.S. Pet Ownership & Demographics Sourcebook, 2002)"
    summary: "households with 1 pet cat 2002"
    correctanswer: 31.6
    status: "inprogress"
  TutorialRounds.insert
    index: 2
    question: "What percent of the world's population speaks Spanish as their first language? (Ethnologue: Languages of the World, 4/2007)"
    summary: "Spanish native speakers 2007"
    correctanswer: 4.88
    status: "inprogress"

  TutorialUsers.remove({})
  TutorialUsers.insert
    username: "Bob"
    rand: Math.random()
  TutorialUsers.insert
    username: "Carol"
    rand: Math.random()

  TutorialAnswers.remove({})

  TutorialChat.remove({})


  Tutorial.remove({})
  Tutorial.insert
    key: "numPages"
    value: 6

  Tutorial.insert
    key: "text"
    index: 0
    value: "In this task, you will play multiple games with other MTurk workers.  In each game, you and other players
            will answer a question and get points based on your answers.  IMPORTANT: Please DO NOT use search engines or
            other resources to look up the answers to these questions.  This would defeat the purpose of this research
            project.  Rather, we hope you treat this as a game and just HAVE FUN."

  Tutorial.insert
    key: "text"
    index: 1
    value: "The game interface is shown below.  You can type your answer in the provided box and click UPDATE to submit
                or update your answer.  Your submitted answer is shown in the red box.  Once you click FINALIZE
                to confirm your answer, it cannot be changed anymore.  Your answer must be a valid number
                from 0 to 100 inclusive, and it will be automatically truncated to 2 decimal places."

  Tutorial.insert
    key: "text"
    index: 2
    showOtherAns: false
    showChatRoom: false
    value: "During the game, you can see the other players' usernames and the status of their answers (submitted,
            updated, or finalized) in the yellow boxes, but you cannot see their answers until the game is fniished.
            Take a look at the status of the other players' answers below."
  Tutorial.insert
    key: "text"
    index: 2
    showOtherAns: true
    showChatRoom: false
    value: "During the game, you can see other players' answers in the yellow boxes as soon as they are submitted and
            whenever they are updated or finalized.  Take a look at the other players' answers below."
  Tutorial.insert
    key: "text"
    index: 2
    showOtherAns: false
    showChatRoom: true
    value: "During the game, you can see the other players' usernames and the status of their answers (submitted,
            updated, or finalized) in the yellow boxes, but you cannot see their answers until the game is fniished.
            You can chat with the other players in the chatroom.  Take a look at the status of the other players'
            answers below and feel free to try the chatroom."
  Tutorial.insert
    key: "text"
    index: 2
    showOtherAns: true
    showChatRoom: true
    value: "During the game, you can see other players' answers in the yellow boxes as soon as they are submitted and
            whenever they are updated or finalized.  You can chat with the other players in the chatroom.  Take a look
            at the other players' answers below and feel free to try the chatroom."

  Tutorial.insert
    key: "text"
    index: 3
    value: "Each game is limited to 1 minute. If the timer runs out before all
            answers are finalized, 50% is used for any missing answer and all answers are finalized automatically."

  Tutorial.insert
    key: "text"
    index: 4
    showBestAns: true
    showAvg: false
    value: "Once all answers are finalized or the timer runs out, the game ends.  There is a 10 second break between
            games.  During this break, you can look at all players' answers, the correct answer, and the best answer(s)
            (closest to the correct answer).  At any time, the table on the right shows the results of all previous
            games."
  Tutorial.insert
    key: "text"
    index: 4
    showBestAns: false
    showAvg: true
    value: "Once all answers are finalized or the timer runs out, the game ends.  There is a 10 second break between
            games.  During this break, you can look at all players' answers, the correct answer, and the average of all
            the answers.  At any time, the table on the right shows the results of all previous games."

  Tutorial.insert
    key: "text"
    index: 5
    showBestAns: true
    showAvg: false
    value: "If your answer is one of the best answer(s), you will be rewarded depending on the accuracy of your answer.
            Otherwise, you get 10 points.
            When all games are finished, the AVERAGE of your points from all games will be converted to your bonus
            payment (100 points = $1). This is the end of the tutorial."
  Tutorial.insert
    key: "text"
    index: 5
    showBestAns: false
    showAvg: true
    value: "Every player will get the same payment which depends on the accuracy of the average answer.
            When all games are finished, the AVERAGE of your points from all games will be converted to your bonus
            payment (100 points = $1). This is the end of the tutorial.  "