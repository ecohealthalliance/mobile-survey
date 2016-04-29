Parse = require 'parse'

Template.survey_admin_forms.onCreated ->
  @subscribed = new ReactiveVar false
  @forms = new Meteor.Collection null
  survey = @data.survey
  self = @

  relation = survey.relation 'forms'
  query = relation.query()
  query.find().then (forms) ->
    self.subscribed.set true
    _.each forms, (form) ->
      formProps =
        parseId: form.id
        title: form.get 'title'
        order: form.get 'order'
      self.forms.insert formProps
  , (obj, error) ->
    toastr.error error.message

Template.survey_admin_forms.helpers
  subscribed: ->
    Template.instance().subscribed.get()
  forms: ->
    Template.instance().forms.find()
    # Forms.find {}, sort: {order: 1}
  hasForms: ->
    Template.instance().forms.find().count()
