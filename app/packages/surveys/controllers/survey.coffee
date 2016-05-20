{Survey} = require 'meteor/gq:models'
{transformObj} = require 'meteor/gq:helpers'

Template.survey.onCreated ->
  @fetched = new ReactiveVar false
  surveyId = @data.id
  instance = @
  query = new Parse.Query Survey
  query.get(surveyId)
    .then (survey) ->
      instance.survey = survey
      attributes = transformObj survey
      instance.surveyAttrs = new ReactiveVar attributes
      instance.fetched.set true
    .fail (error) ->
      toastr error.message

Template.survey.helpers
  survey: ->
    Template.instance().survey
  title: ->
    Template.instance().surveyAttrs.get().title
  surveyAttrs: ->
    Template.instance().surveyAttrs
  data: ->
    instance = Template.instance()
    survey: instance.survey
    formId: instance.data.formId
    questionId: instance.data.questionId
