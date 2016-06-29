{Survey} = require 'meteor/gq:api'

Template.survey.onCreated ->
  @fetched = new ReactiveVar false
  surveyId = @data.id
  instance = @
  query = new Parse.Query Survey
  query.get(surveyId)
    .then (survey) ->
      instance.survey = survey
      instance.surveyDetails = new ReactiveVar
        title: survey.get 'title'
        description: survey.get 'description'
      instance.surveyState = new ReactiveVar survey.get('active')
      instance.fetched.set true
    .fail (error) ->
      toastr error.message

Template.survey.helpers
  survey: ->
    Template.instance().survey
  title: ->
    Template.instance().surveyDetails.get().title
  desciption: ->
    Template.instance().surveyDetails.get().description
  surveyDetails: ->
    Template.instance().surveyDetails
  surveyState: ->
    Template.instance().surveyState
  data: ->
    instance = Template.instance()
    survey: instance.survey
    formId: instance.data.formId
    questionId: instance.data.questionId
    surveyState: instance.surveyState
