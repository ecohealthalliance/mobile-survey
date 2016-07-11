Sort = require 'sortablejs'
{updateSortOrder} = require 'meteor/gq:helpers'

Template.form_list.onCreated ->
  @forms = @data.forms
  @fetched = new ReactiveVar false
  @survey = @data.survey

Template.form_list.onRendered ->
  instance = @
  Meteor.autorun ->
    if instance.forms.findOne()
      Meteor.defer ->
        Sort.create formList,
          handle: '.sortable-handle'
          onSort: (event) ->
            updateSortOrder event, instance.survey, 'forms'

Template.form_list.helpers
  forms: ->
    Template.instance().forms.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms.findOne()
  surveyId: ->
    Template.instance().survey.id

Template.form_list.events
  'click .delete-form': (event, instance) ->
    form = @
    instance.survey.getForm(@objectId)
      .then (form) ->
        form.delete()
      .then ->
        instance.forms.remove form._id
