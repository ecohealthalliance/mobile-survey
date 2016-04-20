do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    # Note: the tests below are taken from
    # Tater and serve as an example

    @When "I click on the test user", ->
      @browser
        .waitForVisible('.users-table')
        .click('.users-table .reactive-table tbody tr')

    @Then "I should be on the user profile page", ->
      @browser
        .waitForVisible('.profile-detail')
