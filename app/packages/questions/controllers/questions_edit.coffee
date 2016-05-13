validator = require 'bootstrap-validator'

Template.questions_edit.onCreated ->
  instance = @
  @type = new ReactiveVar 'inputText'
  @choices = new Meteor.Collection(null)
  @question = new ReactiveVar null
  @data.survey.getForm(@data.formId).then (form) ->
    form.getQuestion(instance.data.questionId).then (question) ->
      instance.question.set question
      instance.type.set question.get('type')
      if question.get('properties').choices
        question.get('properties').choices.forEach (choice) ->
          instance.choices.insert(name: choice)
    , (error) ->
      console.error error
  , (error) ->
    console.error error

Template.questions_edit.onRendered ->
  @$('.question-form').validator()

Template.questions_edit.helpers
  types: ->
    [
      {
        text: 'Multiple Choice'
        name: 'multipleChoice'
      }
      {
        text: 'Checkboxes'
        name: 'checkboxes'
      }
      {
        text: 'Short Answer'
        name: 'shortAnswer'
      }
      {
        text: 'Long Answer'
        name: 'longAnswer'
      }
      {
        text: 'Number'
        name: 'number'
      }
      {
        text: 'Date'
        name: 'date'
      }
      {
        text: 'Datetime'
        name: 'datetime'
      }
      {
        text: 'Scale'
        name: 'scale'
      }
    ]
  type: ->
    Template.instance().type.get()
  question: (key) ->
    Template.instance().question.get()?.attributes
  selected: ->
    @name is Template.instance().type.get()
  choices: ->
    Template.instance().choices.find()

Template.questions_edit.events
  'keyup .choice': (event, instance) ->
    instance.choices.update($(event.currentTarget).data('id'),
      name: $(event.currentTarget).val()
    )
  'click .delete-choice': (event, instance)->
    instance.choices.remove($(event.currentTarget).data('id'))
  'click .type': (event, instance) ->
    typeString = $(event.currentTarget).data 'type'
    instance.type.set(typeString)
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget

    formData = _.object $(form).serializeArray().map(
      ({name, value})-> [name, value]
    )
    questionProperties = _.omit(formData, 'text', '_id')

    unless instance.type.get()
      toastr.error('Please select a type')
      return

    if instance.type.get() == 'multipleChoice' or instance.type.get() == 'checkboxes'
      if instance.choices.find().count() == 0
        toastr.error('Please add some choices')
        return
      else
        choiceStrings = instance.choices.find().map(({name})-> name)
        if _.any(choiceStrings, _.isEmpty)
          toastr.error('Please fill in all the choices')
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

    question =
      text: formData.text
      type: instance.type.get()
      required: questionProperties.required is 'on'
      properties: questionProperties

    instance.question.get().save(question).then ->
      FlowRouter.go("/admin/surveys")

  'click .add-choice': (event, instance)->
    instance.choices.insert {}
