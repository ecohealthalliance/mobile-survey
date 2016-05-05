{Survey, Form, Question} = require '../imports/models'

handleError = (error) ->
  throw new Meteor.Error error.code, error.message

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
    survey.save(fields).then (survey) ->
      survey.id
    , handleError

  createForm: (surveyId, props) ->
    @unblock()
    #TODO Authenticate
    #TODO Validate
    query = new Parse.Query Survey
    query.get(surveyId).then (survey) ->
      survey.createForm(props).then (formId) ->
        formId

  geocode: (address) ->
    geo.geocode(address)

  editForm: (formId, props) ->
    trigger = props.trigger
    if trigger
      if trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)

    query = new Parse.Query Form
    query.get(formId).then (form) ->
      form.save(props).then (form) ->
        form
      , handleError

  updateForm: (formId, form) ->
    @unblock()
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    getForms().update(_id: formId, { $set: form })

  createQuestion: (formId, data) ->
    query = new Parse.Query Form
    query.get(formId).then (form) ->
      form.getLastQuestionOrder().then (lastQuestionOrder) ->
        data.order = ++lastQuestionOrder or 1
        question = new Question()
        question.save(data).then (question) ->
          relation = form.relation 'questions'
          relation.add question
          form.save()
          question.id
        , (obj, error) ->
          handleError 'parse', error
      , (obj, error) ->
        handleError 'parse', error
    , (obj, error) ->
      handleError 'parse', error
