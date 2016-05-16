{buildMeteorCollection} = require 'meteor/gq:helpers'

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
    query.first().then (lastForm) ->
      lastForm?.get('order')

  buildForm: (props) ->
    @getLastFormOrder().then (lastFormOrder) ->
      order = ++lastFormOrder or 1
      title: props.title
      createdBy: Parse.User.current()
      order: order
      trigger: props.trigger

  addForm: (props) ->
    survey = @
    form = new Form()
    @buildForm(props)
      .then (formProps) ->
        form.create(formProps, survey)
      .then (form) ->
        relation = survey.relation 'forms'
        relation.add form
        survey.save()
      .then ->
        form

  remove: ->
    survey = @
    @getForms()
      .then (forms) ->
        _.each forms, (form) -> form.remove()
      .then ->
        survey.destroy()

Form = Parse.Object.extend 'Form',
  create: (props) ->
    form = @
    # Stash the trigger properties and remove from props
    # so they aren't saved to form
    triggerProps = props.trigger
    delete props.trigger
    @save(props)
      .then ->
        form.addTrigger(triggerProps)
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
        question = new Question()
        question.create(props, lastQuestionOrder, form)
      .then (question) ->
        question

  addTrigger: (props) ->
    trigger = new Trigger()
    trigger.create(props, @)
      .then (trigger) ->
        trigger

  getTrigger: ->
    query = @relation('triggers').query()
    query.first()
      .then (trigger) ->
        trigger

  updateTrigger: (props) ->
    @getTrigger().then (trigger) ->
      trigger.update props

  remove: ->
    form = @
    @getTrigger()
      .then (trigger) ->
        trigger.destroy()
      .then ->
        form.getQuestions()
      .then (questions) ->
        _.each questions, (question) -> question.destroy()
      .then ->
        form.destroy()

Trigger = Parse.Object.extend 'Trigger',
  create: (props, form) ->
    trigger = @
    @setProperties props
    @save()
      .then ->
        trigger.addToForm(form)
      .then ->
        trigger

  setProperties: (props) ->
    type = props.type
    @set 'type', type
    properties = props.properties
    if type == 'location'
      @set 'location', new Parse.GeoPoint props.location
      delete props.location
    @set 'properties', properties

  update: (props) ->
    @setProperties(props)
    @save()
      .then (trigger) ->
        trigger

  addToForm: (form) ->
    relation = form.relation 'triggers'
    relation.add @
    form.save()
      .then =>
        @

Question = Parse.Object.extend 'Question',
  create: (props, lastQuestionOrder, form) ->
    question = @
    props.order = ++lastQuestionOrder or 1
    props.createdBy = Parse.User.current()
    question.save(props)
      .then ->
        question.addToForm(form)
      .then ->
        question

  addToForm: (form) ->
    relation = form.relation 'questions'
    relation.add @
    form.save()
      .then =>
        @

module.exports =
  Survey: Survey
  Form: Form
  Question: Question
  Trigger: Trigger
