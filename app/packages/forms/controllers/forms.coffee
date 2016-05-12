Sort = require 'sortablejs'
{updateSortOrder} = require 'meteor/gq:helpers'

Template.forms.onCreated ->
  @fetched = new ReactiveVar false
  @survey = @data.survey
  instance = @

  @survey.getForms(true).then (forms) ->
    instance.forms = forms
    instance.fetched.set true

Template.forms.onRendered ->
  instance = @
  Meteor.autorun ->
    if instance.fetched.get() and instance.forms?.findOne()
      Meteor.defer ->
        Sort.create formList,
          handle: '.sortable-handle'
          onSort: (event) ->
            updateSortOrder event, instance.survey, 'forms'

Template.forms.helpers
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms?.findOne()
  surveyId: ->
    Template.instance().data.survey.id
