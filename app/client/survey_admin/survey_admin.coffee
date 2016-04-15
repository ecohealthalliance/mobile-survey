Template.survey_admin.onCreated ->
  @subscribe 'survey', @data.id

Template.survey_admin.helpers
  survey: ->
    Surveys.findOne _id: Template.instance().data.id
