Template.survey.onCreated ->
  @surveyRV = new ReactiveVar()
  Meteor.call 'getSurvey', @data.id, (err, survey)=>
    @surveyRV.set(survey)

Template.survey.helpers
  surveyTitle: ->
    Template.instance().surveyRV.get()?.title
