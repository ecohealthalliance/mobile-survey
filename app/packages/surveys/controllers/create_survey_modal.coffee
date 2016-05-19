{Survey} = require 'meteor/gq:models'
validator = require 'bootstrap-validator'

Template.create_survey_modal.onCreated ->
  @creating = new ReactiveVar false

Template.create_survey_modal.onRendered ->
  @$('#create-survey-modal').validator()

Template.create_survey_modal.helpers
  creating: ->
    Template.instance().creating.get()

Template.create_survey_modal.events
  'submit form': (event, instance) ->
    event.preventDefault()
    instance.creating.set true
    surveyProps = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    surveyProps.deleted = false
    surveyProps.createdBy = Parse.User.current()
    surveyProps.active = false
    survey = new Survey()
    survey.save(surveyProps)
      .then (survey)->
        $(event.target).closest('.modal').modal('hide')
        window.setTimeout(->
          # Wait for modal to hide so the backdrop won't get stuck open.
          toastr.success('Success')
          FlowRouter.go '/admin/surveys/' + survey.id
        , 300)
      .fail (error)->
        toastr.error(error.message)
      .always ->
        instance.creating.set false
