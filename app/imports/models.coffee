{buildMeteorCollection} = require './helpers'

Survey = Parse.Object.extend 'Survey',
  getForms: (returnMeteorCollection, collection) ->
    query = @relation('forms').query()
    query.find().then (forms) ->
      if returnMeteorCollection and forms
        buildMeteorCollection forms, collection
      else
        forms

  getForm: (formId) ->
    query = @relation('forms').query()
    query.equalTo 'objectId', formId
    query.first().then (form) ->
      form

  getLastFormOrder: ->
    query = @relation('forms').query()
    query.descending 'order'
    query.select 'order'
    query.first().then (lastForm) ->
      lastForm?.get('order')

  buildForm: (props) ->
    @getLastFormOrder().then (lastFormOrder) ->
      props.order = ++lastFormOrder or 1
      title: props.title
      createdBy: Parse.User.current()?
      order: props.order

  addForm: (props) ->
    survey = @
    @buildForm(props).then (formProps) ->
      form = new Form()
      form.create(formProps, survey).then (form) ->
        triggerProps = props.trigger
        if triggerProps
          form.addTrigger(triggerProps, form).then ->
            form.id
        else
          form.id

Form = Parse.Object.extend 'Form',
  getQuestions: (returnMeteorCollection, collection) ->
    query = @relation('questions').query()
    query.find().then (questions) ->
      if returnMeteorCollection and questions
        buildMeteorCollection questions, collection
      else
        questions

  getLastQuestionOrder: ->
    query = @relation('questions').query()
    query.descending 'order'
    query.select 'order'
    query.first().then (lastQuestion) ->
      lastQuestion?.get('order')

  create: (props, survey) ->
    @save(props).then (form) ->
      relation = survey.relation 'forms'
      relation.add form
      survey.save().then ->
        form

  update: (props) ->
    form = @
    # Stash the trigger properties and remove from props
    # so they aren't saved to form
    triggerProps = props.trigger
    delete props.trigger
    @save(props).then ->
      form.updateTrigger(triggerProps).then ->
        form

  addTrigger: (props) ->
    trigger = new Trigger()
    form = @
    trigger.create(props, form).then (triggerId) ->
      triggerId

  getTrigger: ->
    query = @relation('triggers').query()
    query.first().then (trigger) ->
      trigger

  updateTrigger: (props) ->
    @getTrigger().then (trigger) ->
      trigger.update props

Trigger = Parse.Object.extend 'Trigger',
  create: (props, form) ->
    @setProperties props
    @save().then (trigger) =>
      @addToForm(form).then ->
        trigger.id

  setProperties: (props) ->
    @set 'type', props.type
    properties = props.properties
    if props.type == 'datetime'
      properties.datetime = new Date(properties.datetime)
    else
      @set 'location', new Parse.GeoPoint props.location
      delete props.location
    @set 'properties', properties

  update: (props) ->
    @setProperties()
    @save().then (trigger) ->
      trigger

  addToForm: (form) ->
    relation = form.relation 'triggers'
    relation.add @
    form.save()

Question = Parse.Object.extend 'Question'

module.exports =
  Survey: Survey
  Form: Form
  Question: Question
  Trigger: Trigger
