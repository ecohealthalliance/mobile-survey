Template.form_preview.helpers
  hasWidgets: ->
    Widgets.find().count()
  widgets: ->
    data = Template.currentData()
    Widgets.find(form: data._id, {sort: order: 1})

Template.form_preview.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget

    unless form.checkValidity()
      toastr.error('Please fill out all required fields')
      throw new Meteor.Error('Invalid form')

    toastr.success("Success")


Template.form_add.onCreated ->
  @type = new ReactiveVar('inputText')
  @label = new ReactiveVar('')
  @placeholder = new ReactiveVar('')

Template.form_add.helpers
  widgets: ->
    data = Template.currentData()
    Widgets.find(form: data._id, {sort: order: 1})
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

Template.form_add.events
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


Template.form_edit.helpers
  hasWidgets: ->
    Widgets.find().count()
  widgets: ->
    data = Template.currentData()
    Widgets.find(form: data._id, {sort: order: 1})
