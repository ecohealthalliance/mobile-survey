Parse = require 'parse'

Template.surveys.onCreated ->
  @subscribed = new ReactiveVar false
  @surveys = new Meteor.Collection null

Template.surveys.onRendered ->
  self = this
  surveyQuery = new Parse.Query Survey
  surveyQuery.find().then (surveys) ->
    self.subscribed.set true
    _.each surveys, (survey) ->
      surveyProps =
        parseId: survey.id
        title: survey.get 'title'
      self.surveys.insert surveyProps
  , (error) ->
    throw new Meteor.Error 'server', error.message


Template.surveys.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  surveys: ->
    Template.instance().surveys.find()
  surveyCollection: ->
    Template.instance().surveys
