getSurveys = => @Surveys
getForms = => @Forms
getQuestions = => @Questions

Meteor.methods

  createSurvey: (fields) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error(501, 'The title field cannot be empty')
    fields.createdBy = @userId
    getSurveys().insert(fields)

  createForm: (surveyId, props) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    #TODO Authenticate
    #TODO Validate
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

  updateForm: (formId, form) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    getSurveys().findOne
      _id: id

  addQuestion: (formId, data) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    form = getForms().findOne(formId)
    formQuestions = form.questions
    if formQuestions?.length
      lastQuestion = getQuestions().findOne
        _id: { $in: formQuestions }, { sort: order: -1 }
      data.order = ++lastQuestion.order
    else
      data.order = 1
    questionId = getQuestions().insert data
    if questionId
      form.questions.push questionId
      getForms().update(formId, $set: {questions: form.questions})

  removeQuestion: (questionId) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    getForms().find(questions: questionId).forEach (item) ->
      questions = _.without(item.questions, questionId)
      getForms().update(item._id, $set: questions: questions)
    getQuestions().remove questionId
