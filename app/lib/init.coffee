if Meteor.isServer
  Parse = require 'parse/node'

  Meteor.startup ->
    Parse.initialize Meteor.settings.private.parseAppId
    Parse.serverURL = Meteor.settings.private.parseServerUrl
