Form = require './form'
{ buildMeteorCollection, setAdminACL, setUserACL } = require 'meteor/gq:helpers'

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

  buildForm: (props) ->
    order = {
      __op: "Increment"
      amount: 1
    }
    title: props.title
    createdBy: Parse.User.current()
    order: order
    trigger: props.trigger
    deleted: false

  addForm: (props) ->
    survey = @
    form = new Form()
    formProps = @buildForm(props)
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

  ###
    Get users invited to a survey
    @return [Promise] Array of user Parse objects
  ###
  getInvitedUsers: ->
    relation = @relation 'invitedUsers'
    query = relation.query()
    query.find()
      .then (users) ->
        users

  ###
    Remove users from a survey
    @param [Object] user, Parse object of user to remove
  ###
  removeInvitedUser: (userId) ->
    query = new Parse.Query Parse.User
    query.equalTo 'objectId', userId
    query.first()
      .then (user) =>
        relation = @relation 'invitedUsers'
        relation.remove user
        @save()

  ###
    Set read rights of a user
    @param [Boolean] access, Rights
  ###
  setUserACL: (access) ->
    survey = @
    # Fetch all users until we implement invited users.
    # When we do simply call @invitedUsers
    query = new Parse.Query Parse.User
    query.find()
      .then (users) ->
        users.forEach (user) ->
          setUserACL survey, user, access
          survey.save()
            .then ->
              survey.getForms()
            .then (forms) ->
              forms.forEach (form) ->
                form.setUserACL user, access
            .fail (err) ->
              console.log err

module.exports = Survey
