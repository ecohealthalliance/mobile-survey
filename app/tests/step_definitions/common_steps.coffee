do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require 'url'

    @Before (callback) ->
      @server.call 'resetFixture'
      @client.url(url.resolve(process.env.ROOT_URL, '/'))
        .execute (->
          # Meteor.logout()
        ), callback

    @When /^I click "([^"]*)"$/, (selector) ->
      @client
        .waitForVisible(selector)
        .click(selector)

    @When 'I fill in the add survey form', ->
      @client
        .waitForVisible('[name="title"]')
        .setValue('[name="title"]', 'Test Survey')
        .click('#confirm-create-survey')

    @When /^I navigate to "([^"]*)"$/, (relativePath) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, relativePath))

    @Then /^I should( not)? see content "([^"]*)"$/, (shouldNot, text) ->
      @client
        .pause 2000 # Give Blaze enough time to update the <body>
        .getText 'body', (error, visibleText) ->
          match = visibleText?.toString().match(text)
          if shouldNot
            assert.notOk(match)
          else
            assert.ok(match)
