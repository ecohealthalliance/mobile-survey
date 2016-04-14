Template.survey_admin_forms.onCreated ->
  @survey = @data.survey
  # TODO: Limit to those in survey
  @subscribe('forms')

Template.survey_admin_forms.helpers
  forms: ->
    forms = Template.instance().survey?.forms
    if forms
      selector = _.map forms, (obj) -> { _id: obj }
      Forms.find( $or: selector )
    else
      []
  formToEdit: =>
    @Forms.findOne(_id: FlowRouter.getParam('formId'))

Template.survey_admin_forms.events
  'click #add-form': (event, instance)->
    Meteor.call 'createForm', instance.survey._id, (error, formId)->
      if error
        toastr.error('Error')
      else
        FlowRouter.go("""/admin/surveys/#{instance.survey._id}/forms/#{formId}""")
