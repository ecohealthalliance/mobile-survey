do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    @When 'I fill out the edit form form', ->
      @client
        .waitForVisible('input[name="title"]')
        .pause 1000
        .setValue('input[name="title"]', 'Test Form')
        .submit('.edit-form')
        .pause 1000
