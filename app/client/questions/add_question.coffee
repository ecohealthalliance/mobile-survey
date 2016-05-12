validator = require 'bootstrap-validator'
{Survey, Form, Question} = require '../../imports/models'

Template.registerHelper 'match', (val, {hash:{regex}})->
  val?.match new RegExp regex

Template.registerHelper 'isEmpty', (val)->
  if val.count
    val.count() == 0
  else
    _.isEmpty val

Template.add_question.onCreated ->
  @form = @data.form
  @questions = @data.questions
  @type = new ReactiveVar null
  @choices = new Meteor.Collection null

Template.add_question.onRendered ->
  @$('.question-form').validator()

Template.add_question.helpers
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
  selected: ->
    @name is Template.instance().type.get()
  choices: ->
    Template.instance().choices.find()
  questions: ->
    Template.instance().questions.find {}, sort: {order: 1}

Template.add_question.events
  'keyup .choice': (event, instance) ->
    instance.choices.update($(event.currentTarget).data('id'),
      name: $(event.currentTarget).val()
    )
  'click .delete-choice': (event, instance)->
    instance.choices.remove($(event.currentTarget).data('id'))
  'click .type': (event, instance) ->
    instance.type.set $(event.currentTarget).data 'type'
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget

    formData = _.object $(form).serializeArray().map(
      ({name, value})-> [name, value]
    )
    questionProperties = _.omit(formData, 'text', '_id')

    if not instance.type.get()
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
      properties: questionProperties
      required: questionProperties.required is 'on'
    parseForm = null
    query = new Parse.Query Form
    query.get(instance.form.id)
      .then (form) ->
        form.addQuestion(question)
      .then (question) ->
        form.reset()
        instance.choices.find().forEach ({_id})->
          instance.choices.remove _id
        lastItemOrder = instance.questions.findOne({}, sort: {order: -1})?.order
        instance.questions.insert
          parseId: question.id
          order: ++lastItemOrder or 1
          text: question.get 'text'
        toastr.success 'Question added'
      .fail (error) ->
        toastr.error error.message

  'click .add-choice': (event, instance)->
    instance.choices.insert {}
