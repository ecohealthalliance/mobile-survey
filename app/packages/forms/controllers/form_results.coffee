Template.form_results.onCreated ->
  @selectedFormIds = new Meteor.Collection null

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
    Template.instance().selectedFormIds
