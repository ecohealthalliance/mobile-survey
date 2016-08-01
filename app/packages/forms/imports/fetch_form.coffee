###
  Fetches a form with associated questions, submissions and participants
  @param [Object] instance, Blaze Template instance
  @param [String] formId, ObjectId of form
###
fetchForm = (instance, formId) ->
  _submissions = null
  query = new Parse.Query 'Submission'
  query.equalTo 'formId', formId
  query.find()
    .then (submissions) ->
      _submissions = submissions
      # Cache Submissions
      _.each _submissions, (submission) ->
        instance.submissions.insert submission.toJSON()
      query = new Parse.Query 'Form'
      query.get(formId)
    .then (form) ->
      # Cache Form
      instance.form = form.toJSON()
      form.getQuestions()
    .then (questions) ->
      _.each questions, (question, i) ->
        # Cache Questions
        question = question.toJSON()
        question.formId = formId
        question.answers = []
        _submissions.forEach (submission, i) ->
          question.answers.push
            content: submission.get('answers')[question.objectId]
            userId: submission.get('userId').id
            createdAt: submission.get 'createdAt'
        instance.questions.insert question

module.exports = fetchForm
