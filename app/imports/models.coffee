if Meteor.isServer
  Parse = require 'parse/node'
else
  Parse = require 'parse'

exports.Survey = Parse.Object.extend 'Survey',
  getForms: (returnMeteorCollection, collection) ->
    query = @relation('forms').query()
    query.find().then (forms) ->
      if returnMeteorCollection and forms
        formCollection = collection or new Meteor.Collection null
        _.each forms, (form) ->
          props = _.extend {}, form.attributes
          props.parseId = form.id
          formCollection.insert props
        formCollection
      else
        forms

exports.Form = Parse.Object.extend 'Form'
