do ->

  'use strict'

  _ = require 'underscore'

  module.exports = ->

    url = require 'url'
    { fixtures } = require '../../packages/_tests/fixtures'

    getTestSurvey = ->
      new Promise (resolve) ->
        query = new Parse.Query 'Survey'
        query.equalTo 'title', 'Test Survey'
        query.first()
          .then (survey) ->
            resolve survey

    getForm = ->
      that = this
      new Promise (resolve) ->
        getTestSurvey()
          .then (survey) ->
            survey.getForms()
          .then (forms) ->
            forms[0]

    @Before ->
      fixtures.setFixture()
      fixtures.createUserFixture()
      @client.url url.resolve(process.env.ROOT_URL, '/')


    @Given 'there is a test user in the database', ->
      fixtures.createUserFixture()

    @Given 'there is a survey in the database', ->
      fixtures.createSurveyFixture()

    @Given 'there is a form in Test Survey', ->
      getTestSurvey.then (survey) =>
        fixtures.createSurveyFixture survey

    @Given 'there are questions of every type in Test Form', ->
      getForm()
        .then (form) =>
          fixtures.createTestQuestions form

    @When /^I navigate to "([^"]*)"$/, (relativePath) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, relativePath))

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
        .pause 2000

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
