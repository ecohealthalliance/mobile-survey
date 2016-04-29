Parse = require 'parse/node'

# getSurveys = => @Surveys
getForms = => @Forms
getQuestions = => @Questions

geo = new GeoCoder(
  geocoderProvider: "google",
  httpAdapter: "https",
  apiKey: Meteor.settings.googleApiKey
)

Meteor.methods
  createSurvey: (fields) ->
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    fields.createdBy = @userId
    survey = new Survey()
    survey.save(fields).then ((survey) ->
      survey.id
    ), (error) ->
      throw new Meteor.Error error

  createForm: (surveyId, props)->
    #TODO Authenticate
    #TODO Validate
    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
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
          title: props.name
          trigger: trigger
          createdBy: @userId
          questions: []
          order: order or 1
          parent: survey
        form = new Form()

        form.save(formProps).then (form) ->
          # Set relation for new form
          relation = survey.relation 'forms'
          relation.add form
          survey.save()
          form.id
        , (ob, error) ->
          throw new Meteor.Error 'server', error.message

  geocode: (address) ->
    geo.geocode(address)

  editForm: (formId, props) ->
    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)
    getForms().update(_id: formId, { $set: props })

  updateForm: (formId, form)->
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    getSurveys().findOne
      _id: id

  addQuestion: (formId, data) ->
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
    getForms().find(questions: questionId).forEach (item) ->
      questions = _.without(item.questions, questionId)
      getForms().update(item._id, $set: questions: questions)
    getQuestions().remove questionId
