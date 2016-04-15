Template.survey_admin_forms_new.onCreated ->
  @survey = @data.survey

Template.survey_admin_forms_new.events
  'submit form': (event, instance)->
    event.preventDefault()
    form = event.currentTarget
    props =
      name: form.name.value
    Meteor.call 'createForm', instance.survey._id, props, (error, formId)->
      if error
        toastr.error('Error')
      else
        FlowRouter.go("""/admin/surveys/#{instance.survey._id}/forms/#{formId}""")
