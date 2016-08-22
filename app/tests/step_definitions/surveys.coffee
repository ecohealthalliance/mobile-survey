do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    @When 'I fill out the add survey form', ->
      @client
        .waitForVisible('input[name="title"]')
        .pause 1000
        .setValue('input[name="title"]', 'Test Survey')
        .click('#confirm-create-survey')
        .pause 1000
