if Meteor.isServer
  Parse = require 'parse/node'
else
  Parse = require 'parse'

Parse.initialize Meteor.settings.public.parseAppId
Parse.serverURL = Meteor.settings.public.parseServerUrl
