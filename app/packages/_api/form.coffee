Trigger = require './trigger'
Question = require './question'
{ buildMeteorCollection, setAdminACL } = require 'meteor/gq:helpers'

Form = Parse.Object.extend 'Form',
  create: (props) ->
    form = @
    # Stash the trigger properties and remove from props
    # so they aren't saved to form
    triggerProps = props.trigger
    delete props.trigger
    setAdminACL(form)
      .then ->
        form.save(props)
      .then ->
        form.addTrigger(triggerProps)
      .then ->
        form
      .fail (err) ->
        console.log err

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

module.exports = Form
