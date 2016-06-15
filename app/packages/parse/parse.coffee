if Meteor.isServer
  Parse = require 'parse/node'
  Parse.initialize Meteor.settings.public.parseAppId, null, Meteor.settings.private.parseMasterKey
  Parse.serverURL = Meteor.settings.public.parseServerUrl
else
  Parse = require 'parse'
  Parse.initialize Meteor.settings.public.parseAppId
  Parse.serverURL = Meteor.settings.public.parseServerUrl
