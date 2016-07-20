###
  Fetches a form with associated questions, submissions and participants
  @param [Object] instance, Blaze Template instance
  @param [String] formId, ObjectId of form
###
fetchForm = (instance, formId) ->
  fetched = instance.fetched
  fetched.set false
  query = new Parse.Query 'Submission'
  query.equalTo 'formId', formId
  query.each (submission) ->
    instance.submissions.insert submission.toJSON()
  .then ->
    query = new Parse.Query 'Form'
    query.get(formId)
  .then (form) ->
    instance.form = form.toJSON()
    form.getQuestions()
  .then (questions) ->
    _.each questions, (question, i) ->
      question = question.toJSON()
      question.formId = formId
      instance.questions.insert question
    query = new Parse.Query Parse.User
    query.find()
  .then (participants) ->
    participants.forEach (participant) ->
      _participant = participant.toJSON()
      instance.participants.insert _participant
    fetched.set true

module.exports = fetchForm
