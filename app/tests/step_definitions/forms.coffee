do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    @When 'I fill out the edit form form', ->
      @client
        .waitForVisible('input[name="name"]')
        .pause 1000
        .setValue('input[name="name"]', 'Test Form')
        .pause 1000
        .submitForm('.edit-form')
        .pause 1000
