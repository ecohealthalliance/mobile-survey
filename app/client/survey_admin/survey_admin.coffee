Parse = require 'parse'

Template.survey_admin.onCreated ->
  @subscribed = new ReactiveVar false
  surveyId = @data.id
  self = @

  query = new Parse.Query Survey
  query.get(surveyId).then (survey) ->
      self.subscribed.set true
      self.survey = survey
    ,
    (obj, error) ->
      throw new Meteor.Error 'server', error.message

Template.survey_admin.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  survey: ->
    Template.instance().survey
  data: ->
    instanceData = Template.instance().data
    surveyId: instanceData.id
    formId: instanceData.formId
