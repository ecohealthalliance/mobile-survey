@Forms = new Meteor.Collection(null)
@Widgets = new Meteor.Collection(null)

# Default form
form_id = Forms.insert(name: "Test form")

# Dummy widgets
Widgets.insert
  form: form_id
  type: "inputText"
  label: "Your Name"
  name: "name"
  value: "John Doe"
  required: true
  data:
    placeholder: "Please Specify Your Full Name"
    maxlength: 20
Widgets.insert
  form: form_id
  type: "textArea"
  label: "Short bio"
  name: "bio"
  data:
    placeholder: "Tell a little about yourself"
    maxlength: 20


Template.container.helpers
  forms: ->
    Forms.find()


Template.form_preview.helpers
  widgets: ->
    data = Template.currentData()
    Widgets.find(form: data._id)

Template.form_preview.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget

    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    toastr.success("Success")


Template.widget.helpers
  widgetTemplateName: ->
    data = Template.currentData()
    return "widget.#{data.type}"


Template.form_edit.onCreated ->
  @type = new ReactiveVar('inputText')
  @label = new ReactiveVar('')
  @placeholder = new ReactiveVar('')

Template.form_edit.helpers
  widgets: ->
    data = Template.currentData()
    Widgets.find(form: data._id)
  types: ->
    [
      {
        label: 'Simple Text Input'
        name: 'inputText'
      },
      {
        label: 'Text Area'
        name: 'textArea'
      }
    ]
  previewData: ->
    [
      form: "preview"
      type: Template.instance().type.get()
      label: Template.instance().label.get()
      name: "dummy"
      data:
        placeholder: Template.instance().placeholder.get()
    ]

Template.form_edit.events
  'change #new-type': (event, instance) ->
    instance.type.set(event.currentTarget.value)
  'input #new-label': (event, instance) ->
    instance.label.set(event.currentTarget.value)
  'input #new-placeholder': (event, instance) ->
    instance.placeholder.set(event.currentTarget.value)
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    data = instance.data

    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    if Widgets.find(form: data._id, name: form.name.value.trim()).count()
      toastr.error('Please specify a unique system name')
      throw new Meteor.Error('Duplicate field')

    Widgets.insert
      form: data._id
      type: form.type.value
      label: form.label.value.trim()
      name: form.name.value.trim()
      data:
        placeholder: form.placeholder.value.trim()

    form.reset()
    instance.type.set('inputText')
    instance.label.set('')
    instance.placeholder.set('')

    toastr.success("Added new field")
