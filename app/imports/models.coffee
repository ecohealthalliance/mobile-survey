{buildMeteorCollection} = require './helpers'

Survey = Parse.Object.extend 'Survey',
  validate: (props) ->
    if props?.title?.length == 0
      return new Parse.Error(Parse.VALIDATION_ERROR, 'The title field cannot be empty')
    Parse.Object.prototype.validate.call(this, props)

  getForms: (returnMeteorCollection, collection) ->
    query = @relation('forms').query()
    query.find()
      .then (forms) ->
        if returnMeteorCollection and forms
          buildMeteorCollection forms, collection
        else
          forms

  getForm: (formId) ->
    query = @relation('forms').query()
    query.equalTo 'objectId', formId
    query.first()
      .then (form) ->
        form

  getLastFormOrder: ->
    query = @relation('forms').query()
    query.descending 'order'
    query.select 'order'
    query.first()
      .then (lastForm) ->
        lastForm?.get('order')

  buildForm: (props) ->
    @getLastFormOrder().then (lastFormOrder) ->
      props.order = ++lastFormOrder or 1
      title: props.title
      createdBy: Parse.User.current()?
      order: props.order

  addForm: (props) ->
    survey = @
    form = new Form()
    @buildForm(props)
      .then (formProps) ->
        form.create(formProps, survey)
      .then (form) ->
        form

Form = Parse.Object.extend 'Form',
  create: (props, survey) ->
    form = @
    @save(props)
      .then ->
        form.addTrigger(props.trigger)
      .then ->
        relation = survey.relation 'forms'
        relation.add form
        survey.save()
      .then ->
        form

  getQuestions: (returnMeteorCollection, collection) ->
    query = @relation('questions').query()
    query.find()
      .then (questions) ->
        if returnMeteorCollection and questions
          buildMeteorCollection questions, collection
        else
          questions

  getLastQuestionOrder: ->
    query = @relation('questions').query()
    query.descending 'order'
    query.select 'order'
    query.first()
      .then (lastQuestion) ->
        lastQuestion?.get('order')

  getQuestion: (questionId) ->
    query = @relation('questions').query()
    query.equalTo 'objectId', questionId
    query.first()
      .then (question) ->
        question

  addQuestion: (props) ->
    form = @
    @getLastQuestionOrder()
      .then (lastQuestionOrder) ->
        props.order = ++lastQuestionOrder or 1
        question = new Question()
        question.save(props)
      .then (question) ->
        question.addToForm(form)
      .then ->
        question.id

  create: (props, survey) ->
    @save(props)
      .then (form) ->
        relation = survey.relation 'forms'
        relation.add form
        survey.save()
      .then ->
        form

  update: (props) ->
    form = @
    # Stash the trigger properties and remove from props
    # so they aren't saved to form
    triggerProps = props.trigger
    delete props.trigger
    @save(props)
      .then ->
        form.updateTrigger(triggerProps)
      .then ->
        form

  addQuestion: (props) ->
    form = @
    @getLastQuestionOrder()
      .then (lastQuestionOrder) ->
        props.order = ++lastQuestionOrder or 1
        question = new Question()
        question.save(props)
          .then (question) ->
            relation = form.relation 'questions'
            relation.add question
            form.save().then ->
              question

  addTrigger: (props) ->
    trigger = new Trigger()
    trigger.create(props, @)
      .then (triggerId) ->
        triggerId

  getTrigger: ->
    query = @relation('triggers').query()
    query.first()
      .then (trigger) ->
        trigger

  updateTrigger: (props) ->
    @getTrigger().then (trigger) ->
      trigger.update props

Trigger = Parse.Object.extend 'Trigger',
  create: (props, form) ->
    @setProperties props
    @save()
      .then (trigger) =>
        @addToForm(form)
      .then ->
        trigger.id

  setProperties: (props) ->
    @set 'type', props.type
    properties = props.properties
    if props.type == 'location'
      @set 'location', new Parse.GeoPoint props.location
      delete props.location
    @set 'properties', properties

  update: (props) ->
    @setProperties()
    @save()
      .then (trigger) ->
        trigger

  addToForm: (form) ->
    relation = form.relation 'triggers'
    relation.add @
    form.save()


Question = Parse.Object.extend 'Question',
  addToForm: (form) ->
    relation = form.relation 'questions'
    relation.add @
    form.save()

module.exports =
  Survey: Survey
  Form: Form
  Question: Question
  Trigger: Trigger
