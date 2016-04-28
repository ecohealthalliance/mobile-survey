Parse = require 'parse'

Template.surveys.onCreated ->
  @subscribed = new ReactiveVar false

Template.surveys.onRendered ->
  self = this
  surveyQuery = new Parse.Query Survey
  surveyQuery.find().then ((surveys) ->
    self.subscribed.set true
    self.surveys = surveys
  ), (error) ->
    throw new Meteor.Error 'server', error.message

Template.surveys.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  surveys: ->
    Template.instance().surveys
