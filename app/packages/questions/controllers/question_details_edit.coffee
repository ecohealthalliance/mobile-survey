validator = require 'bootstrap-validator'
questionTypes = require '../imports/question_types'

Template.question_details_edit.onCreated ->
  instance = @
  @survey = @data.survey
  @question = @data.survey
  @type = new ReactiveVar 'inputText'
  @choices = new Meteor.Collection(null)
  @submitting = new ReactiveVar false
  @typeError = new ReactiveVar null

Template.question_details_edit.onRendered ->
  @$('#question-form-edit').validator()

Template.question_details_edit.helpers
  types: -> questionTypes
  type: ->
    Template.instance().type.get()
  question: ->
    instance = Template.instance()
    if instance.question.get()
      Meteor.defer ->
        instance.$('#question-form-edit').validator()
      instance.question.get()?.attributes
  selected: ->
    @name is Template.instance().type.get()
  choices: ->
    Template.instance().choices.find()
  typeInvalid: ->
    Template.instance().submitting.get() and not Template.instance().type.get()
  choicesInvalid: ->
    Template.instance().submitting.get() and Template.instance().typeError.get()
  choiceInvalidMessage: ->
    Template.instance().typeError.get()

Template.question_details_edit.events
  'keyup .choice': (event, instance) ->
    instance.choices.update($(event.currentTarget).data('id'),
      name: $(event.currentTarget).val()
    )

  'click .delete-choice': (event, instance)->
    instance.choices.remove($(event.currentTarget).data('id'))

  'click .type': (event, instance) ->
    typeString = $(event.currentTarget).data 'type'
    instance.type.set(typeString)

  'submit #question-form-edit': (event, instance) ->
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
      required: questionProperties.required is 'on'
      properties: questionProperties

    instance.question.get().save(question).then ->
      data = instance.data
      FlowRouter.go("/surveys/#{data.id}/forms/#{data.formId}")
      instance.$('#question-form-edit').validator('destroy')

  'click .add-choice': (event, instance)->
    instance.choices.insert {}
