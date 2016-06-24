Template.form_details.onCreated ->
  @fetched = new ReactiveVar false
  @questionCollection = new Meteor.Collection null
  @survey = @data.survey
  instance = @
  @survey.getForm(@data.formId)
    .then (form) ->
      instance.form = form
      instance.fetched.set true
    .fail (error) ->
      toastr.error error.message

Template.form_details.helpers
  form: ->
    Template.instance().form
  questionsCollection: ->
    Template.instance().questionCollection

Template.form_details.events
 'click .delete-form': (event, instance) ->
   survey = instance.survey
   survey.getForm(instance.data.formId)
    .then (form) ->
      form.delete()
    .then ->
      FlowRouter.go "/surveys/#{survey.id}"
