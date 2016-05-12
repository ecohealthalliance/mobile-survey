getSurveys = => @Surveys
getForms = => @Forms
getQuestions = => @Questions

Meteor.methods
  createSurvey: (fields)->
    check(fields, Object)
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    fields.createdBy = @userId
    getSurveys().insert(fields)

  createForm: (surveyId, props)->
    #TODO Authenticate
    #TODO Validate
    check(surveyId, String)
    surveyForms = getSurveys().findOne(surveyId).forms
    if surveyForms?.length
      lastForm = getForms().findOne
        _id: {$in: surveyForms}, {sort: order: -1}
      order = ++lastForm.order
    else
      order = 1
    formId = getForms().insert
      name: props.name
      trigger: props.trigger
      createdBy: @userId
      questions: []
      order: order
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  updateForm: (formId, form)->
    check(formId, String)
    check(form, Object)
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    check(id, String)
    getSurveys().findOne
      _id: id

  addQuestion: (formId, data) ->
    check(formId, String)
    form = getForms().findOne(formId)
    formQuestions = form.questions
    if formQuestions?.length
      lastQuestion = getQuestions().findOne
        _id: {$in: formQuestions}, {sort: order: -1}
      data.order = ++lastQuestion.order
    else
      data.order = 1
    questionId = getQuestions().insert data
    if questionId
      form.questions.push questionId
      getForms().update(formId, $set: {questions: form.questions})

  removeQuestion: (questionId) ->
    check(questionId, String)
    getForms().find(questions: questionId).forEach (item) ->
      questions = _.without(item.questions, questionId)
      getForms().update(item._id, $set: questions: questions)
    getQuestions().remove questionId
