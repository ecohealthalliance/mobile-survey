Form = require './form'
{ buildMeteorCollection, setAdminACL } = require 'meteor/gq:helpers'

Survey = Parse.Object.extend 'Survey',
  validate: (props) ->
    if props?.title?.length == 0
      return new Parse.Error(Parse.VALIDATION_ERROR, 'The title field cannot be empty')
    Parse.Object.prototype.validate.call(this, props)

  create: (props) ->
    setAdminACL(@)
      .then =>
        @save props

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
    if @get 'active'
      return new Parse.Error OPERATION_FORBIDDEN, 'Survey is active and cannot be deleted.'
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

module.exports = Survey
