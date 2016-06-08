{ Survey }       = require 'meteor/gq:api'

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
      instance.surveys.insert survey.toJSON()
  , (error) ->
    throw new Meteor.Error 'server', error.message

Template.surveys.helpers
  surveys: ->
    Template.instance().surveys.find()
  surveyCollection: ->
    Template.instance().surveys
