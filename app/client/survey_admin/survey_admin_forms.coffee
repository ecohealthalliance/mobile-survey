Template.survey_admin_forms.onCreated ->
  @survey = @data.survey

Template.survey_admin_forms.helpers
  forms: ->
    forms = Template.instance().survey?.forms
    if forms
      selector = _.map forms, (obj) -> { _id: obj }
      Forms.find( $or: selector )
    else
      []
