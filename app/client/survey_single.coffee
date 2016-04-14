Template.survey_single.onCreated ->
  @surveyRV = new ReactiveVar()
  Meteor.call 'getSurvey', @data.id, (err, survey) =>
    @surveyRV.set(survey)

Template.survey_single.helpers
  surveyTitle: ->
    Template.instance().surveyRV.get()?.title
