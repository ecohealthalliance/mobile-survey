getSurveys = => @Surveys
getForms = => @Forms
getQuestions = => @Questions

Meteor.methods
  createSurvey: (fields)->
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    fields.createdBy = @userId
    getSurveys().insert(fields)

  createForm: (surveyId, props)->
    #TODO Authenticate
    surveyForms = getSurveys().findOne(surveyId).forms
    if surveyForms?.length
      lastForm = getForms().findOne
        _id: {$in: surveyForms}, {sort: order: -1}
      order = ++lastForm.order
    else
      order = 1
    formId = getForms().insert
      name: props.name
      createdBy: @userId
      questions: []
      order: order
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  updateForm: (formId, form)->
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    getSurveys().findOne
      _id: id

  addQuestion: (formId, data) ->
    form = Forms.findOne(formId)
    formQuestions = form.questions
    if formQuestions?.length
      lastQuestion = getQuestions().findOne
        _id: {$in: formQuestions}, {sort: order: -1}
      data.order = ++lastQuestion.order
    else
      data.order = 1
    questionId = Questions.insert data
    if questionId
      form.questions.push questionId
      Forms.update(formId, $set: {questions: form.questions})

  removeQuestion: (questionId) ->
    Forms.find(questions: questionId).forEach (item) ->
      questions = _.without(item.questions, questionId)
      Forms.update(item._id, $set: questions: questions)
    Questions.remove questionId
