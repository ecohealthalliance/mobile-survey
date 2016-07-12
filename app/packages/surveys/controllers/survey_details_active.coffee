activate = require '../imports/activation'

Template.survey_details_active.onCreated ->
  @survey = @data.survey
  @surveyDetails = @data.surveyDetails
  @active = new ReactiveVar @data.survey.get 'active'
  @activating = new ReactiveVar false

Template.survey_details_active.helpers
  description: ->
    Template.instance().surveyDetails.get().description

  forms: ->
    Template.instance().data.forms.find {}, sort: {order: 1}

  activating: ->
    Template.instance().activating.get()

Template.survey_details_active.events
  'click .de-activate': (event, instance) ->
    activate instance
