'use strict'

{Survey, Form, Trigger, Question} = require 'meteor/gq:api'
{ questions } = require './imports/data'

Meteor.methods

  resetFixture: ->
    # Reset the local Meteor+Parse data, grant yourself write permissions
    if Meteor.settings.public.parseServerUrl.match(/localhost|127\.0\.0\.1/)
      console.log("Resetting the local database...")
      # Reset the local Meteor database (Note: logs the user out)
      Package['xolvio:cleaner'].resetDatabase()
      # Create Parse User
    else
      console.warn 'The Parse database is not local, we do not reset it.'

  createUserFixture: ->
    email = Meteor.settings.public.parseUserEmail
    pass = Meteor.settings.public.parseUserPassword

    # Create Meteor user
    Accounts.createUser
      email: email
      password: pass

    # Create Parse User
    user = new Parse.User()
    user.set "username", email
    user.set "password", pass
    user.set "email", email
    user.signUp(null)
      .then ->
        acl = new Parse.ACL
        acl.setPublicReadAccess true
        adminRole = new Parse.Role 'admin', acl
        adminRole.relation("users").add user
        adminRole.save()

  createSurveyFixture: ->
    props =
      title: 'Test Survey'
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Et
                    ille ridens: Video, inquit, quid agas; Omnia contraria, quos
                    etiam insanos esse vultis.'
      createdBy: Parse.User.current()
      deleted: false
      active: false
    survey = new Survey()
    survey.create props

  createFormFixture: (survey) ->
    props =
      title: 'Test Form'
      deleted: false
      trigger:
        deleted: false
        datetime: new Date()
        type: 'datetime'
    survey.addForm props

  createQuestionsFixture: (form) ->
    _.each questions, (question, index) ->
      props =
        text: question.text
        type: question.type
        properties: question.properties
        order: index

      question = new Question()
      question.create(props, index-1, form)
