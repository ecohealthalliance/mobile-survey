###
Template.form_preview.helpers
  hasQuestions: ->
    Questions.find().count()
  questions: ->
    data = Template.currentData()
    Questions.find(form: data._id, {sort: order: 1})

Template.form_preview.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget

    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    toastr.success("Success")
###


Template.form_add.onCreated ->
  @type = new ReactiveVar 'inputText'
  @text = new ReactiveVar ''
  @placeholder = new ReactiveVar ''

Template.form_add.helpers
  types: ->
    [
      {
        text: 'Simple Input'
        name: 'inputText'
      },
      {
        text: 'Text Area'
        name: 'textArea'
      }
    ]
  previewData: ->
    [
      form: "preview"
      type: Template.instance().type.get()
      text: Template.instance().text.get()
      name: "dummy"
      data:
        placeholder: Template.instance().placeholder.get()
    ]
  selected: ->
    @name is Template.instance().type.get()

Template.form_add.events
  'click .type': (event, instance) ->
    instance.type.set $(event.currentTarget).data 'type'
  'input #new-label': (event, instance) ->
    instance.text.set(event.currentTarget.value)
  'input #new-placeholder': (event, instance) ->
    instance.placeholder.set(event.currentTarget.value)
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    data = instance.data

    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    name = form.label.value.trim().replace(/\s+/g, '-').toLowerCase()

    question =
      question_type: instance.type.get()
      text: form.label.value.trim()
      properties:
        placeholder: form.placeholder.value.trim()

    Meteor.call "addQuestion", data._id, question, (error, response) ->
      if error
        toastr.error("Something went wrong")
      else
        form.reset()
        instance.type.set('inputText')
        instance.text.set('')
        instance.placeholder.set('')
        toastr.success("Question added")


Template.form_edit.onCreated ->
  form_id = Template.instance().data.formId
  @autorun =>
    @subscribe 'questions', Forms.findOne(form_id).questions

Template.form_edit.helpers
  hasQuestions: ->
    Questions.find().count()
  questions: ->
    Questions.find()
    # data = Template.currentData()
    # selector = _.map data.questions, (obj) -> { _id: obj }
    # Questions.find($or: selector, {sort: {order: 1}})
