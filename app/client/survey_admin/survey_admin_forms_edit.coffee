Template.survey_admin_forms_edit.onCreated ->
  @surveyId = @data.surveyId
  @formId = @data.formId
  @subscribe 'form', @formId

Template.survey_admin_forms_edit.helpers
  form: ->
    Forms.findOne _id: Template.instance().formId

Template.survey_admin_forms_edit.events
  'submit form': (event, instance)->
    event.preventDefault()
    formId = instance.formId
    form = event.currentTarget
    props =
      name: form.name.value
    if formId
      Meteor.call 'editForm', formId, props, (error)->
        if error
          toastr.error('Error')
        else
          FlowRouter.go "/admin/surveys/#{instance.surveyId}/forms/#{formId}"
    else
      Meteor.call 'createForm', instance.surveyId, props, (error, formId)->
        if error
          toastr.error 'Error'
        else
          FlowRouter.go "/admin/surveys/#{instance.surveyId}/forms/#{formId}"
