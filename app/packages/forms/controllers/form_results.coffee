Template.form_results.onCreated ->
  @selectedFormIdCollection = new Meteor.Collection null
  @selectedFormIds = new ReactiveVar []

Template.form_results.onRendered ->
  instance = @
  @autorun =>
    _selectedFormIds = @selectedFormIdCollection.find {}, {fields: {id: 1}}
    @selectedFormIds.set _.pluck(_selectedFormIds.fetch(), 'id')

Template.form_results.helpers
  formCollection: ->
    forms =
      collection: Template.instance().data.forms
      settings:
        name: 'Forms'
        key: 'title'
        selectable: true
        selectAll: true
    [forms]

  selectedFormIds: ->
    Template.instance().selectedFormIdCollection

  forms: ->
    ids = Template.instance().selectedFormIds.get()
    Template.instance().data.forms.find objectId: {$in: ids}
