{Survey, Form, Question} = require 'meteor/gq:api'
validator = require 'bootstrap-validator'
questionTypes = require '../imports/question_types'

Template.questions_add.onCreated ->
  @form = @data.form
  @questions = @data.questions
  @type = new ReactiveVar null
  @choices = new Meteor.Collection null
  @submitting = new ReactiveVar false
  @typeError = new ReactiveVar null

Template.questions_add.onRendered ->
  @$('#question-form-add').validator()

Template.questions_add.helpers
  types: -> questionTypes
  type: ->
    Template.instance().type.get()
  selected: ->
    @name is Template.instance().type.get()
  choices: ->
    Template.instance().choices.find()
  questions: ->
    Template.instance().questions.find {}, sort: {order: 1}
  typeInvalid: ->
    Template.instance().submitting.get() and not Template.instance().type.get()
  choicesInvalid: ->
    Template.instance().submitting.get() and Template.instance().typeError.get()
  choiceInvalidMessage: ->
    Template.instance().typeError.get()

Template.questions_add.events
  'keyup .choice': (event, instance) ->
    instance.choices.update($(event.currentTarget).data('id'),
      name: $(event.currentTarget).val()
    )
  'click .delete-choice': (event, instance)->
    instance.choices.remove($(event.currentTarget).data('id'))
  'click .type': (event, instance) ->
    instance.type.set $(event.currentTarget).data 'type'
  'submit form': (event, instance) ->
    if event.isDefaultPrevented() # If form is invalid
      return
    event.preventDefault()
    instance.submitting.set true
    form = event.currentTarget
    unless instance.type.get()
      return

    formData = _.object $(form).serializeArray().map(
      ({name, value})-> [name, value]
    )
    questionProperties = _.omit(formData, 'text', '_id')

    if instance.type.get() == 'multipleChoice' or instance.type.get() == 'checkboxes'
      if instance.choices.find().count() == 0
        instance.typeError.set 'Please add choices to the question'
        return
      else
        choiceStrings = instance.choices.find().map(({name})-> name)
        if _.any(choiceStrings, _.isEmpty)
          instance.typeError.set 'Please fill in all choices to the question'
          return
        instance.typeError.set null
        questionProperties.choices = choiceStrings

    if questionProperties.min?.length
      questionProperties.min = Number(questionProperties.min)
    else
      delete questionProperties.min

    if questionProperties.max?.length
      questionProperties.max = Number(questionProperties.max)
    else
      delete questionProperties.max

    question =
      text: formData.text
      type: instance.type.get()
      properties: questionProperties
      required: questionProperties.required is 'on'

    instance.form.addQuestion(question)
      .then (question) ->
        instance.submitting.set false
        form.reset()
        instance.choices.find().forEach ({_id})->
          instance.choices.remove _id
        lastItemOrder = instance.questions.findOne({}, sort: {order: -1})?.order
        instance.questions.insert
          objectId: question.id
          order: ++lastItemOrder or 1
          text: question.get 'text'
        instance.$('#question-form-add').validator('destroy')
        toastr.success 'Question added'
      .fail (error) ->
        toastr.error error.message

  'click .add-choice': (event, instance)->
    instance.choices.insert {}
