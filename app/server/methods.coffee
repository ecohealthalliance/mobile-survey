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
