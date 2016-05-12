{Survey} = require 'meteor/gq:models'

Template.delete_survey_modal.onCreated ->
  @deleting = new ReactiveVar false

Template.delete_survey_modal.onRendered ->
  $('#delete-survey-modal').on 'show.bs.modal', (event) =>
    @surveyId = $(event.relatedTarget).data 'id'

Template.delete_survey_modal.helpers
  deleting: ->
    Template.instance().deleting.get()

Template.delete_survey_modal.events
  'submit form': (event, instance) ->
    event.preventDefault()
    instance.data.surveys.remove parseId: instance.surveyId
    query = new Parse.Query Survey
    query.get(instance.surveyId)
      .then (survey) ->
        survey.destroy()
      .then (obj) ->
        $('#delete-survey-modal').modal('hide')
        instance.deleting.set false
      .fail (error) ->
        toastr.error error.message
