###
  Fetches a form with associated questions, submissions and participants
  @param [Object] instance, Blaze Template instance
  @param [String] formId, ObjectId of form
###
fetchForm = (instance, formId) ->
  query = new Parse.Query 'Submission'
  query.equalTo 'formId', formId
  query.each (submission) ->
    instance.submissions.insert submission.toJSON()
  .then ->
    query = new Parse.Query 'Form'
    query.get(formId)
  .then (form) ->
    form.getQuestions()
  .then (questions) ->
    _.each questions, (question, i) ->
      question = question.toJSON()
      question.formId = formId
      instance.questions.insert question
    participants = instance.participants.find().fetch()
    _.each participants, (particpant) ->
      if instance.submissions.findOne('userId.objectId': particpant.objectId)
        instance.participantsWithSubmissions.insert particpant

module.exports = fetchForm
