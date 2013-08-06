Template.tutorial.events =
  "click #goToQuiz": (ev) ->
    Meteor.Router.to("/quiz")

  "click #nextPage": (ev) ->
    data =
      userId: Meteor.user()._id
      change : 1

    Meteor.call "incrTutorialPage", data, (error, result) ->
      if error
        return bootbox.alert error.reason

    if Template.tutorial.getTreatmentType() is "competitive-bestanswer" or Template.tutorial.getTreatmentType() is "cooperative-average"

      if Template.tutorial.getIndex() is 1
        data =
          userId: Meteor.user()._id
        Meteor.call "clearAliceAnswer", data, (error, result) ->
          if error
            return bootbox.alert error.reason
      else if Template.tutorial.getIndex() is 3
        data =
          userId: Meteor.user()._id
        Meteor.call "finalizeAliceAnswer", data, (error, result) ->
          if error
            return bootbox.alert error.reason

  "click #previousPage": (ev) ->
    data =
      userId: Meteor.user()._id
      change : -1
    Meteor.call "incrTutorialPage", data, (error, result) ->
      if error
        return bootbox.alert error.reason

    if Template.tutorial.getTreatmentType() is "competitive-bestanswer" or Template.tutorial.getTreatmentType() is "cooperative-average"
      if Template.tutorial.getIndex() is 2 or Template.tutorial.getIndex() is 1
        data =
          userId: Meteor.user()._id
        Meteor.call "clearAliceAnswer", data, (error, result) ->
          if error
            return bootbox.alert error.reason


Template.tutorial.getTreatmentType = ->
  tre = Treatment.findOne()
  return null unless tre
  return tre.value

Template.tutorial.getIndex = ->
  counter = TutorialCounter.findOne({userId: Meteor.user()._id})
  return -1 unless counter
  return counter.index

Template.tutorial.getTutObj = ->
  tre = Treatment.findOne()
  return null unless tre
  return TutorialText.findOne {type: tre.value}

Template.tutorial.getTutorialText = ->
  index = Template.tutorial.getIndex()
  tutObj = Template.tutorial.getTutObj()
  return null unless tutObj

  return tutObj.text[index]

 Template.tutorial.lastStep = ->
  index = Template.tutorial.getIndex()
  tutObj = Template.tutorial.getTutObj()
  return null unless tutObj
  return index is Object.keys(tutObj.text).length - 1

Template.tutorial.disablePrevious = ->
  index = Template.tutorial.getIndex()
  if index is 0
    return "disabled"
  return ""

Template.tutorial.disableNext = ->
  if Template.tutorial.lastStep()
    return "disabled"
  return ""

Template.tutorial.getPageNum = ->
  return Template.tutorial.getIndex() + 1

Template.tutorial.getTotalPageNum = ->
  tutObj = Template.tutorial.getTutObj()
  return unless tutObj
  return Object.keys(tutObj.text).length

Template.tutorial.shouldDisplayInterface = ->
  return Template.tutorial.getIndex() > 0


