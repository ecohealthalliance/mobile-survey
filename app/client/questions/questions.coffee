Sort = require 'sortablejs'
{updateSortOrder} = require '../../imports/list_helpers'

Template.questions.onCreated ->
  @fetched = new ReactiveVar false
  @form = @data.form
  instance = @
  @form.getQuestions(true).then (questions) ->
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
