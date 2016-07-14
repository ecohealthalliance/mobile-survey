Template.form_results.onCreated ->
  @selectedFormIdCollection = new Meteor.Collection null
  @selectedFormIds = new ReactiveVar []
  @fetched = new ReactiveVar true
  @submissions = new Meteor.Collection null
  @queriedFormIds = new Meteor.Collection null
  @lastClickedFormId = new ReactiveVar null

Template.form_results.onRendered ->
  instance = @
  @autorun ->
    fetched = instance.fetched
    queriedFormIds = instance.queriedFormIds
    _queriedFormIds = _.pluck queriedFormIds.find().fetch(), 'id'
    lastClickedFormId = instance.lastClickedFormId.get()

    fetched.set false
    if not lastClickedFormId and lastClickedFormId in _queriedFormIds
      fetched.set true
    else
      query = new Parse.Query 'Submission'
      query.equalTo 'formId', lastClickedFormId
      query.each (submission) ->
        instance.submissions.insert submission.toJSON()
      .always ->
        fetched.set true

    if lastClickedFormId
      query = id: lastClickedFormId
      queriedFormIds.upsert query, query

    _selectedFormIds = instance.selectedFormIdCollection.find {}, {fields: {id: 1}}
    instance.selectedFormIds.set _.pluck(_selectedFormIds.fetch(), 'id')


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

  lastClickedFormId: ->
    Template.instance().lastClickedFormId

  submissions: ->
    Template.instance().submissions.find formId: @objectId
