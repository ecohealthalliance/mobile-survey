{Survey} = require 'meteor/gq:models'

Template.surveys.onCreated ->
  @fetched = new ReactiveVar false
  @surveys = new Meteor.Collection null

Template.surveys.onRendered ->
  instance = @
  query = new Parse.Query Survey
  query.equalTo 'deleted', false
  query.find().then (surveys) ->
    instance.fetched.set true
    _.each surveys, (survey) ->
      surveyProps =
        parseId: survey.id
        title: survey.get 'title'
      instance.surveys.insert surveyProps
  , (error) ->
    throw new Meteor.Error 'server', error.message

Template.surveys.helpers
  surveys: ->
    Template.instance().surveys.find()
  surveyCollection: ->
    Template.instance().surveys
