validator = require 'bootstrap-validator'
questionTypes = require '../imports/question_types'
{ mostCommonItem } = require 'meteor/gq:helpers'


Template.question_details_edit.onCreated ->
  @surveyId   = @data.surveyId
  @form       = @data.form
  @question   = @data.question
  @questions  = @data.questions
  @choices    = @data.choices or new Meteor.Collection null
  @type       = @data.type or new ReactiveVar null
  @submitting = new ReactiveVar false
  @typeError  = new ReactiveVar null

Template.question_details_edit.onRendered ->
  @$('#question-form-edit').validator()

Template.question_details_edit.helpers
  types: -> questionTypes

  type: ->
    Template.instance().type.get()

  question: ->
    Template.instance().question?.toJSON()

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

    type = instance.type.get()
    form = event.currentTarget

    unless type
      return

    formData = _.object $(form).serializeArray().map(
      ({name, value})-> [name, value]
    )
    questionProperties = _.omit(formData, 'text', '_id')

    if type in ['multipleChoice', 'checkboxes']
      if instance.choices.find().count() == 0
        instance.typeError.set 'Please add choices to the question'
        return
      else
        choiceStrings = instance.choices.find().map(({name})-> name)
        if _.any(choiceStrings, _.isEmpty)
          instance.typeError.set 'Please fill in all choices to the question'
          return
        instance.typeError.set null
        # Check the array of choices for duplicates
        if mostCommonItem(choiceStrings)
          instance.typeError.set 'All choices must be unique'
          return
        questionProperties.choices = choiceStrings

    if questionProperties.min?.length
      questionProperties.min = Number(questionProperties.min)
    else
      delete questionProperties.min

    if questionProperties.max?.length
      questionProperties.max = Number(questionProperties.max)
    else
      delete questionProperties.max

    props =
      text: formData.text
      type: type
      required: questionProperties.required is 'on'
      properties: questionProperties

    if instance.question
      instance.question.save(props)
        .then ->
          FlowRouter.go("/surveys/#{instance.surveyId}/forms/#{instance.form.id}")
        .fail (err) ->
          toastr.error err.message
    else
      instance.form.addQuestion(props)
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
          toastr.success 'Question added'
        .fail (error) ->
          toastr.error error.message

  'click .add-choice': (event, instance)->
    instance.choices.insert {}
