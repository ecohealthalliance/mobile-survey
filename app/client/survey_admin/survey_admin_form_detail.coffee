Template.survey_admin_form_details.onCreated ->
  @subscribe 'form', @data.formId if @data.formId?

Template.survey_admin_form_details.helpers
  form: ->
    Forms.findOne _id: Template.instance().data.formId
