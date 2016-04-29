Parse = require 'parse'
Sort = require 'sortablejs'

Template.survey_admin_forms.onCreated ->
  @subscribed = new ReactiveVar false
  @forms = new Meteor.Collection null
  survey = @data.survey
  instance = @

  relation = survey.relation 'forms'
  query = relation.query()
  query.find().then (forms) ->
    instance.subscribed.set true
    _.each forms, (form) ->
      formProps =
        parseId: form.id
        title: form.get 'title'
        order: form.get 'order'
      instance.forms.insert formProps
  , (obj, error) ->
    toastr.error error.message

Template.survey_admin_forms.onRendered ->
  instance = @
  Meteor.autorun ->
    subscribed = instance.subscribed.get()
    Meteor.defer ->
      if subscribed
        el = document.getElementById 'forms'
        sortable = new Sort el,
          handle: '.sortable-handle'
          onSort: (event) ->
            console.log event

Template.survey_admin_forms.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  forms: ->
    Template.instance().forms.find()
    # Forms.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms.find().count()
  surveyId: ->
    Template.instance().data.survey.id
