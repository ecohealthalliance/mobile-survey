Parse = require 'parse'
Sort = require 'sortablejs'

updateFormOrder = (event) ->
  instance = @
  formId = $(event.item).data 'id'
  oldOrder = ++event.oldIndex
  newOrder = ++event.newIndex

  # Get the moved form's Parse object
  relation = instance.survey.relation 'forms'
  formQuery = relation.query()
  formQuery.get(formId).then (form) ->
    movingUp = form.get('order') > newOrder
    # Build query to get other effected forms in list
    otherFormsQuery = relation.query()
    if movingUp
      otherFormsQuery.greaterThanOrEqualTo 'order', newOrder
    else
      otherFormsQuery.greaterThan 'order', oldOrder
      otherFormsQuery.lessThanOrEqualTo 'order', newOrder
    otherFormsQuery.notEqualTo 'objectId', form.id
    otherFormsQuery.ascending 'order'
    otherFormsQuery.select 'order'
    # Run query and increment/decrement order of each obj according to the
    # direction the original item was moved. Parse does not allow the each
    # method called on queries with sorting
    otherFormsQuery.find().then (otherForms) ->
      _.each otherForms, (otherForm) ->
        otherFormOrder = otherForm.get('order')
        if movingUp then ++otherFormOrder else --otherFormOrder
        otherForm.set 'order', otherFormOrder
        otherForm.save()
    # Set new order of moved list item and save
    form.set 'order', newOrder
    form.save()

Template.survey_admin_forms.onCreated ->
  @subscribed = new ReactiveVar false
  @forms = new Meteor.Collection null
  @survey = @data.survey
  instance = @
  relation = @survey.relation 'forms'
  formQuery = relation.query()

  formQuery.each (form) ->
    instance.subscribed.set true
    console.log form.get 'order'
    formProps =
      parseId: form.id
      title: form.get 'title'
      order: form.get 'order'
    instance.forms.insert formProps
  , (obj, error) ->
    toastr.error error.message

Template.survey_admin_forms.onRendered ->
  instance = @
  Meteor.autorun ->
    subscribed = instance.subscribed.get()
    Meteor.defer ->
      if subscribed
        Sort.create forms,
          handle: '.sortable-handle'
          onSort: _.bind updateFormOrder, instance

Template.survey_admin_forms.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms?.findOne()
  surveyId: ->
    Template.instance().data.survey.id
