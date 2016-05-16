{Survey} = require 'meteor/gq:models'

Template.survey.onCreated ->
  @fetched = new ReactiveVar false
  surveyId = @data.id
  instance = @
  query = new Parse.Query Survey
  query.get(surveyId)
    .then (survey) ->
      instance.fetched.set true
      instance.survey = survey
    .fail (error) ->
      toastr error.message

Template.survey.helpers
  survey: ->
    Template.instance().survey
  data: ->
    instance = Template.instance()
    survey: instance.survey
    formId: instance.data.formId
    questionId: instance.data.questionId
