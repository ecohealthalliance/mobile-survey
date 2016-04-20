Template.survey_admin_forms.onCreated ->
  survey = @data.survey
  if survey.forms
    @subscribe 'surveyForms', survey.forms

Template.survey_admin_forms.helpers
  forms: ->
    Forms.find {}, sort: {order: 1}

  formToEdit: =>
    @Forms.findOne(_id: FlowRouter.getParam('formId'))