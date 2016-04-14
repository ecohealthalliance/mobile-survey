Template.survey_admin.onCreated ->
  @surveyRV = new ReactiveVar()
  Meteor.call 'getSurvey', @data.id, (err, survey) =>
    @surveyRV.set(survey)

Template.survey_admin.helpers
  forms: ->
    forms = Template.instance().surveyRV.get()?.forms
    if forms
      selector = _.map forms, (obj) -> { _id: obj }
      Forms.find( $or: selector )
    else
      []
  title: ->
    Template.instance().surveyRV.get()?.title
  description: ->
    Template.instance().surveyRV.get()?.description