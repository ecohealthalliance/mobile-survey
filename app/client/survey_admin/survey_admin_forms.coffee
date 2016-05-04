Parse = require 'parse'
Sort = require 'sortablejs'
{updateSortOrder} = require '../../imports/list_helpers'

Template.survey_admin_forms.onCreated ->
  @fetched = new ReactiveVar false
  @survey = @data.survey
  instance = @

  @survey.getForms(true).then (forms) ->
    instance.forms = forms
    instance.fetched.set true

Template.survey_admin_forms.onRendered ->
  instance = @
  Meteor.autorun ->
    fetched = instance.fetched.get()
    Meteor.defer ->
      if fetched and instance.forms?.findOne()
        Sort.create document.getElementById 'forms',
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
