{Survey} = require '../../imports/models'

Template.survey_admin.onCreated ->
  @fetched = new ReactiveVar false
  surveyId = @data.id
  instance = @

  query = new Parse.Query Survey
  query.get(surveyId).then (survey) ->
    instance.fetched.set true
    instance.survey = survey
  , (obj, error) ->
    throw new Meteor.Error 'server', error.message

Template.survey_admin.helpers
  survey: ->
    Template.instance().survey
  data: ->
    instance = Template.instance()
    survey: instance.survey
    formId: instance.data.formId
