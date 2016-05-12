if Meteor.isClient
  BlazeLayout.setRoot('body')


FlowRouter.route '/',
  action: ->
    if Meteor.user()
      FlowRouter.go '/admin/surveys'
    else
      FlowRouter.go 'login'

adminRoutes = FlowRouter.group
  prefix: '/admin'
  name: 'admin'
  triggersEnter: [ ->
    unless Meteor.loggingIn() or Meteor.userId()
      route = FlowRouter.current()
      FlowRouter.go 'login'
  ]


adminRoutes.route '/surveys',
  name: 'surveys'
  action: ->
    BlazeLayout.render 'layout',
      main: 'surveys'

adminRoutes.route '/surveys/:id',
  name: 'survey_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

adminRoutes.route '/surveys/:id/forms',
  name: 'forms'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

adminRoutes.route '/surveys/:id/users',
  name: 'survey_users'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

adminRoutes.route '/surveys/:id/forms/:formId/edit',
  name: 'form_edit'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

adminRoutes.route '/surveys/:id/forms/new',
  name: 'form_edit'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

adminRoutes.route '/surveys/:id/forms/:formId',
  name: 'form_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params

# Edit Question
adminRoutes.route '/surveys/:id/forms/:formId/questions/:questionId/edit',
  name: 'questions_edit'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params
