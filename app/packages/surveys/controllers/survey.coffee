{Survey} = require 'meteor/gq:api'

Template.survey.onCreated ->
  @fetched = new ReactiveVar false
  surveyId = @data.id
  instance = @
  query = new Parse.Query Survey
  query.get(surveyId)
    .then (survey) ->
      instance.surveyAttrs = new ReactiveVar instance.survey.toJSON()
      instance.fetched.set true
    .fail (error) ->
      toastr error.message

Template.survey.helpers
  survey: ->
    Template.instance().survey
  title: ->
    Template.instance().surveyAttrs.get().title
  active: ->
    Template.instance().surveyAttrs.get().active
  surveyAttrs: ->
    Template.instance().surveyAttrs
  data: ->
    instance = Template.instance()
    survey: instance.survey
    formId: instance.data.formId
    questionId: instance.data.questionId
