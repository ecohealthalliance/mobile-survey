Template.registerHelper 'match', (val, {hash:{regex}})->
  val.match(new RegExp(regex))

Template.registerHelper 'isEmpty', (val)->
  if val.count
    val.count() == 0
  else
    _.isEmpty val

Template.add_question.onCreated ->
  @form = @data.form
  @type = new ReactiveVar 'inputText'
  @choices = new Meteor.Collection(null)

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
    
    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    formData = _.object $(form).serializeArray().map(
      ({name, value})-> [name, value]
    )
    questionProperties = _.omit(formData, 'text', '_id')

    if not instance.type.get()
      toastr.error('Please select a type')
      throw new Meteor.Error('Invalid form')

    if instance.type.get() == 'multipleChoice' or instance.type.get() == 'checkboxes'
      console.log instance.choices
      if instance.choices.find().count() == 0
        toastr.error('Please add some choices')
        throw new Meteor.Error('Invalid form')
      else
        choiceStrings = instance.choices.find().map(({name})-> name)
        if _.any(choiceStrings, _.isEmpty)
          toastr.error('Please fill in all the choices')
          throw new Meteor.Error('Invalid form')
        questionProperties.choices = choiceStrings

    questionProperties.required = questionProperties.required is 'on'
    
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
      question_type: instance.type.get()
      properties: questionProperties

    console.log question
    Meteor.call "addQuestion", instance.form._id, question, (error, response) ->
      if error
        toastr.error("Something went wrong")
      else
        form.reset()
        instance.choices.find().forEach ({_id})->
          instance.choices.remove(_id)
        instance.type.set('inputText')
        toastr.success('Question added')
  'click .add-choice': (event, instance)->
    instance.choices.insert({})