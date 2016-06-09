{Survey} = require 'meteor/gq:api'
validator = require 'bootstrap-validator'

Template.edit_survey_modal.onCreated ->
  @surveys = @data.surveys
  @saving = new ReactiveVar false
  @survey = @data.survey
  @surveyAttrs = @data.surveyAttrs
  @surveyObjectId = new ReactiveVar @survey?.id
  @fetched = new ReactiveVar false

Template.edit_survey_modal.onRendered ->
  @$('#edit-survey-modal').validator()
  $('#edit-survey-modal').on 'show.bs.modal', (event) =>
    @fetched.set false
    @surveyObjectId.set $(event.relatedTarget).data 'id'

Template.edit_survey_modal.helpers
  saving: ->
    Template.instance().saving.get()
  survey: ->
    Template.instance().surveyAttrs?.get()

afterSurveySave = (isNewSurvey, survey, instance, event) ->
  instance.saving.set false
  $(event.target).closest('.modal').modal 'hide'
  if isNewSurvey
    window.setTimeout(->
      # Wait for modal to hide so the backdrop won't get stuck open.
      toastr.success 'Success'
      FlowRouter.go '/surveys/' + survey.id
    , 300)
  else
    # Update the existing details
    instance.surveyAttrs.set survey.toJSON()

Template.edit_survey_modal.events
  'submit form': (event, instance) ->
    event.preventDefault()
    instance.saving.set true
    surveyProps = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    survey = instance.survey
    if survey
      survey.save(surveyProps)
        .then (survey) ->
          afterSurveySave(false, survey, instance, event)
        .fail (error)   ->
          toastr.error(error.message)
        .always ->
          instance.saving.set false
    else
      surveyProps.createdBy = Parse.User.current()
      surveyProps.deleted = false
      surveyProps.active = false
      survey = new Survey()
      survey.create(surveyProps)
        .then (survey) ->
          afterSurveySave(true, survey, instance, event)
        .fail (error) ->
          toastr.error(error.message)
