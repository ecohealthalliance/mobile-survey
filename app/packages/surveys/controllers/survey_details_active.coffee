Template.survey_details_active.onCreated ->
  @survey = @data.survey
  @surveyDetails = @data.surveyDetails

Template.survey_details_active.helpers
  description: ->
    Template.instance().surveyDetails.get().description

  forms: ->
    Template.instance().data.forms.find {}, sort: {order: 1}
