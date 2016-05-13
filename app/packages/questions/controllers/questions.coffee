Sort = require 'sortablejs'
{updateSortOrder} = require 'meteor/gq:helpers'
{Question} = require 'meteor/gq:models'

Template.questions.onCreated ->
  @fetched = new ReactiveVar false
  @survey = @data.survey
  @questions = @data.questions
  @form = @data.form
  instance = @
  @form.getQuestions(true, @questions).then (questions) ->
    instance.fetched.set true
    instance.questions = questions

Template.questions.onRendered ->
  instance = @
  instance.autorun ->
    if instance.fetched.get() and instance.questions?.findOne()
      Meteor.defer ->
        Sort.create questionList,
          handle: '.sortable-handle'
          onSort: (event) ->
            updateSortOrder event, instance.form, 'questions'

Template.questions.helpers
  surveyId: ->
    Template.instance().survey.id
  formId: ->
    Template.instance().form.id
  hasQuestions: ->
    Template.instance().questions?.findOne()
  questions: ->
    Template.instance().questions?.find {}, sort: {order: 1}

Template.questions.events
  'click .delete': (event, instance) ->
    query = new Parse.Query Question
    query.get(@parseId).then (question) =>
      question.destroy().then () =>
        instance.questions.remove @_id
