Parse = require 'parse/node'

getSurveys = => @Surveys
getForms = => @Forms
getQuestions = => @Questions

geo = new GeoCoder(
  geocoderProvider: "google",
  httpAdapter: "https",
  apiKey: Meteor.settings.googleApiKey
)

Meteor.methods
  createSurvey: (fields) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error(501, 'The title field cannot be empty')
    fields.createdBy = @userId
    survey = new Survey()
    survey.save(fields).then ((survey) ->
      survey.id
    ), (error) ->
      throw new Meteor.Error error

  createForm: (surveyId, props) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    #TODO Authenticate
    #TODO Validate

    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)

    surveyForms = getSurveys().findOne(surveyId).forms
    if surveyForms?.length
      lastForm = getForms().findOne
        _id: {$in: surveyForms}, {sort: order: -1}
      order = ++lastForm.order
    else
      order = 1
    formId = getForms().insert
      name: props.name
      trigger: trigger
      createdBy: @userId
      questions: []
      order: order
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  geocode: (address) ->
    geo.geocode(address)

  editForm: (formId, props) ->
    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)
    getForms().update(_id: formId, { $set: props })

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
