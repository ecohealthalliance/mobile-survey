do ->

  'use strict'

  _ = require('underscore')
  {Survey, Form, Trigger, Question} = require 'meteor/gq:api'

  module.exports = ->

    url = require 'url'

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

    @Before (callback) ->
      @server.call 'resetFixture'
      @client.url(url.resolve(process.env.ROOT_URL, '/'))


    @Given 'There is a survey in the database', ->
      @server.call 'createSurveyFixture'

    @Given 'There is a form in Test Survey', ->
      getTestSurvey.then (survey) =>
        @server.call 'createSurveyFixture', survey

    @Given 'There are questions of every type in Test Form', ->
      getForm()
        .then (form) =>
          @server.call 'createTestQuestions', form


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
