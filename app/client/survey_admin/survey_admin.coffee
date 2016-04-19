Template.survey_admin.onCreated ->
  @subscribe 'survey', @data.id

Template.survey_admin.helpers
  survey: ->
    Surveys.findOne _id: Template.instance().data.id
  data: ->
    instanceData = Template.instance().data
    surveyId: instanceData.id
    formId: instanceData.formId
