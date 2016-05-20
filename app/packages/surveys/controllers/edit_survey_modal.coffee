{Survey} = require 'meteor/gq:models'
validator = require 'bootstrap-validator'
{transformObj} = require 'meteor/gq:helpers'

Template.edit_survey_modal.onCreated ->
  @surveys = @data.surveys
  @saving = new ReactiveVar false
  @survey = @data.survey
  @surveyAttrs = @data.surveyAttrs
  @surveyParseId = new ReactiveVar @survey?.id
  @fetched = new ReactiveVar false

Template.edit_survey_modal.onRendered ->
  @$('#edit-survey-modal').validator()
  $('#edit-survey-modal').on 'show.bs.modal', (event) =>
    @fetched.set false
    @surveyParseId.set $(event.relatedTarget).data 'id'

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
      FlowRouter.go '/admin/surveys/' + survey.id
    , 300)
  else
    # Update the existing details
    attributes = transformObj survey
    instance.surveyAttrs.set attributes

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
      survey.save(surveyProps)
        .then (survey) ->
          afterSurveySave(true, survey, instance, event)
        .fail (error) ->
          toastr.error(error.message)