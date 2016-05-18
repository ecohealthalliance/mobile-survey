do ->

  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require 'url'

    @Before (callback) ->
      @server.call 'resetFixture'
      @client.url(url.resolve(process.env.ROOT_URL, '/'))

    @When /^I click "([^"]*)"$/, (selector) ->
      @client
        .waitForVisible(selector)
        .click(selector)

    @When 'I sign in', ->
      @client
        .waitForVisible('input#inputEmail')
        .setValue('input#inputEmail', 'yursky555@blurg.com')
        .setValue('input#inputPassword', 'P@ssw0rd')
        .submitForm('input#inputEmail')

    @When 'I fill out the add survey form', ->
      @client
        .waitForVisible('input[name="title"]')
        .pause 1000
        .setValue('input[name="title"]', 'Test Survey')
        .click('#confirm-create-survey')
        .pause 1000

    @When /^I navigate to "([^"]*)"$/, (relativePath) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, relativePath))

    @Then /^I should( not)? see content "([^"]*)"$/, (shouldnt, text) ->
      @client
        .pause 2000 # Give Blaze enough time to update the <body>
        .getText 'body', (error, visibleText) ->
          match = visibleText?.toString().match(text)
          if shouldnt
            assert.notOk(match)
          else
            assert.ok(match)
