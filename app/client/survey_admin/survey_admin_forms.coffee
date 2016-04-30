Parse = require 'parse'
Sort = require 'sortablejs'
{updateSortOrder} = require '../../imports/list_helpers'

Template.survey_admin_forms.onCreated ->
  @fetched = new ReactiveVar false
  @forms = new Meteor.Collection null
  @survey = @data.survey
  instance = @

  relation = @survey.relation 'forms'
  formQuery = relation.query()
  formQuery.each (form) ->
    instance.fetched.set true
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
    fetched = instance.fetched.get()
    Meteor.defer ->
      if fetched
        Sort.create forms,
          handle: '.sortable-handle'
          onSort: (event) ->
            updateSortOrder(event, instance.survey, 'forms')

Template.survey_admin_forms.helpers
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms?.findOne()
  surveyId: ->
    Template.instance().data.survey.id
