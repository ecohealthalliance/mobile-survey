Parse = require 'parse'
Sort = require 'sortablejs'
{updateSortOrder} = require '../../imports/helpers'
{Question} = require '../../imports/models'

Template.questions.onCreated ->
  @fetched = new ReactiveVar false
  @questions = @data.questions
  @form = @data.form
  instance = @
  @form.getQuestions(true, @questions).then (questions) ->
    instance.fetched.set true
    instance.questions = questions

Template.questions.onRendered ->
  instance = @
  Meteor.autorun ->
    if instance.fetched.get() and instance.questions?.findOne()
      Meteor.defer ->
        Sort.create questions,
          handle: '.sortable-handle'
          onSort: (event) ->
            updateSortOrder event, instance.form, 'questions'

Template.questions.helpers
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
