do ->

  'use strict'

  Meteor.methods

    resetFixture: ->
      Package['xolvio:cleaner'].resetDatabase()
