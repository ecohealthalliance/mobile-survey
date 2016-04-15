Template.survey_admin_forms.onCreated ->
  @survey = @data.survey
  # TODO: Limit to those in survey
  @subscribe 'forms'
  @creatingForm = new ReactiveVar false

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

  creatingForm: ->
    Template.instance().creatingForm.get()
