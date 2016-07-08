Template.form_results.onCreated ->
  @selectedFormIdCollection = new Meteor.Collection null
  @selectedFormIds = new ReactiveVar []

Template.form_results.onRendered ->
  instance = @
  @autorun =>
    _selectedFormIds =
      _.map @selectedFormIdCollection.find().fetch(), (form) -> form.id
    @selectedFormIds.set _selectedFormIds

Template.form_results.helpers
  formCollection: ->
    forms =
      collection: Template.instance().data.forms
      settings:
        name: 'Forms'
        key: 'title'
        selectable: true
    [forms]

  selectedFormIds: ->
    Template.instance().selectedFormIdCollection

  forms: ->
    ids = Template.instance().selectedFormIds.get()
    Template.instance().data.forms.find objectId: {$in: ids}
