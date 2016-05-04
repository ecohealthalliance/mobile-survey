if Meteor.isServer
  Parse = require 'parse/node'
else
  Parse = require 'parse'

exports.Survey = Parse.Object.extend 'Survey'
exports.Form = Parse.Object.extend 'Form'
