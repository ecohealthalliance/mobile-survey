Template.survey_admin.onCreated ->
  @surveyRV = new ReactiveVar()
  @autorun =>
    Meteor.call 'getSurvey', FlowRouter.getParam('id'), (err, survey) =>
      @surveyRV.set(survey)

Template.survey_admin.helpers
  detailsActive: ->
    if FlowRouter.getParam('page') is 'details'
      'active'
    else if not FlowRouter.getParam('page')
      'active'
  formsActive: ->
    if FlowRouter.getParam('page') is 'forms' then 'active'
  usersActive: ->
    if FlowRouter.getParam('page') is 'users' then 'active'
  survey: ->
    Template.instance().surveyRV.get()
