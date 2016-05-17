{buildMeteorCollection} = require 'meteor/gq:helpers'

Survey = Parse.Object.extend 'Survey',
  validate: (props) ->
    if props?.title?.length == 0
      return new Parse.Error(Parse.VALIDATION_ERROR, 'The title field cannot be empty')
    Parse.Object.prototype.validate.call(this, props)

  getForms: (returnMeteorCollection, collection, limit) ->
    query = @relation('forms').query()
    if limit == 'deleted'
      query.equalTo 'deleted', true
    else if not limit
      query.notEqualTo 'deleted', true
    query.find()
      .then (forms) ->
        if returnMeteorCollection and forms
          buildMeteorCollection forms, collection
        else
          forms

  getDeletedForms: (returnMeteorCollection, collection) ->
    @getForms(returnMeteorCollection, collection, 'deleted')
      .then (forms) ->
        forms

  getAllForms: (returnMeteorCollection, collection) ->
    @getForms(returnMeteorCollection, collection, 'all')
      .then (forms) ->
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
      deleted: false

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

  deleteForms: (deleted = true) ->
    @getForms(false, null, 'all')
      .then (forms) ->
        _.each forms, (form) ->
          form.delete(deleted)

  undeleteForms: () ->
    @getForms(false, null, 'deleted')
      .then (forms) ->
        _.each forms, (form) ->
          form.delete(false)


  delete: (deleted = true) ->
    survey = @
    @deleteForms(deleted)
      .then ->
        survey.set 'deleted', deleted
        survey.save()

  undelete: ->
    @delete(false)

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

  getQuestions: (returnMeteorCollection, collection, limit) ->
    query = @relation('questions').query()
    if limit == 'deleted'
      query.equalTo 'deleted', true
    else if not limit
      query.notEqualTo 'deleted', true
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

  getDeletedQuestions: (returnMeteorCollection, collection) ->
    @getQuestions(returnMeteorCollection, collection, 'deleted')
      .then (questions) ->
        questions

  getAllQuestions: (returnMeteorCollection, collection) ->
    @getQuestions(returnMeteorCollection, collection, 'all')
      .then (questions) ->
        questions

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
        props.deleted = false
        question.create(props, lastQuestionOrder, form)
      .then (question) ->
        question

  addTrigger: (props) ->
    trigger = new Trigger()
    props.deleted = false
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

  delete: (deleted = true) ->
    form = @
    @getTrigger()
      .then (trigger) ->
        trigger.delete(deleted)
      .then (trigger) ->
        form.getQuestions()
      .then (questions) ->
        _.each questions, (question) ->
          question.delete(deleted)
      .then ->
        form.set 'deleted', deleted
        form.save()

  undelete: ->
    @delete(false)

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

  delete: (deleted = true) ->
    @set 'deleted', deleted
    @save()

  undelete: ->
    @delete(false)

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

  delete: (deleted = true) ->
    @set 'deleted', deleted
    @save()

  undelete: ->
    @delete(false)

module.exports =
  Survey: Survey
  Form: Form
  Question: Question
  Trigger: Trigger
