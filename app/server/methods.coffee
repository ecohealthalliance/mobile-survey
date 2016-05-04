Parse = require 'parse/node'
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
    unless @userId then throw new Meteor.Error(500, 'Not Authorized')
    #TODO Authenticate
    #TODO Validate
    trigger = props.trigger
    if trigger and trigger.type == 'datetime'
      trigger.datetime = new Date trigger.datetime

    query = new Parse.Query Survey
    query.get(surveyId).then (survey) ->
      # Get the order prop of the last form of survey to set order of new form
      relation = survey.relation 'forms'
      query = relation.query()
      query.descending 'order'
      query.select 'order'
      query.first().then (lastForm) ->
        if lastForm
          order = lastForm.get('order') + 1
        formProps =
          title: props.title
          trigger: trigger
          createdBy: @userId
          order: order or 1
        form = new Form()

        form.save(formProps).then (form) ->
          # Set relation for new form
          relation = survey.relation 'forms'
          relation.add form
          survey.save()
          form.id
        , handleError

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
