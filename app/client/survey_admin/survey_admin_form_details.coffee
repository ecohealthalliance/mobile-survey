Parse = require 'parse'

Template.survey_admin_form_details.onCreated ->
  @fetched = new ReactiveVar false
  @questionCollection = new Meteor.Collection null
  survey = @data.survey
  instance = @
  relation = survey.relation 'forms'
  query = relation.query()
  query.equalTo 'objectId', @data.formId
  query.first().then (form) ->
    instance.form = form
    instance.fetched.set true
  , (form, error) ->
    toastr.error error.message

Template.survey_admin_form_details.helpers
  form: ->
    Template.instance().form
  questionsCollection: ->
    Template.instance().questionCollection
