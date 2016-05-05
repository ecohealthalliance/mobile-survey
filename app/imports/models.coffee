Survey = Parse.Object.extend 'Survey',
  getForms: (returnMeteorCollection, collection) ->
    query = @relation('forms').query()
    query.find().then (forms) ->
      if returnMeteorCollection and forms
        formCollection = collection or new Meteor.Collection null
        _.each forms, (form) ->
          props = _.extend {}, form.attributes
          props.parseId = form.id
          formCollection.insert props
        formCollection
      else
        forms

  getForm: (formId) ->
    query = @relation('forms').query()
    query.equalTo 'objectId', formId
    query.first().then (form) ->
      form
    , (form, error) ->
      error

  getLastFormOrder: ->
    query = @relation('forms').query()
    query.descending 'order'
    query.select 'order'
    query.first().then (lastForm) ->
      lastForm?.get('order')

  createForm: (props) ->
    survey = @
    @getLastFormOrder().then (lastFormOrder) ->
      props.order = ++lastFormOrder or 1
      trigger = props.trigger
      if trigger and trigger.type == 'datetime'
        trigger.datetime = new Date trigger.datetime
      formProps =
        title: props.title
        trigger: trigger
        createdBy: Parse.User.current()?
        order: props.order
      form = new Form()
      form.create(formProps, survey).then (formId) ->
        formId

Form = Parse.Object.extend 'Form',
  getQuestions: (returnMeteorCollection, collection) ->
    query = @relation('questions').query()
    query.find().then (questions) ->
      if returnMeteorCollection and questions
        questionCollection = collection or new Meteor.Collection(null)
        _.each questions, (question) ->
          props = _.extend {}, question.attributes
          props.parseId = question.id
          questionCollection.insert props
        questionCollection
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
        form.id

  addTrigger: ->
    return

Question = Parse.Object.extend 'Question'

module.exports =
  Survey: Survey
  Form: Form
  Question: Question
