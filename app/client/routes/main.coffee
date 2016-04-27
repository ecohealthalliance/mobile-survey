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
  action: ->
    BlazeLayout.render 'layout',
      main: 'surveys'

adminRoutes.route '/surveys/:id',
  name: 'survey_admin_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

adminRoutes.route '/surveys/:id/forms',
  name: 'survey_admin_forms'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

adminRoutes.route '/surveys/:id/users',
  name: 'survey_admin_users'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

adminRoutes.route '/surveys/:id/forms/:formId/edit',
  name: 'survey_admin_forms_edit'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

adminRoutes.route '/surveys/:id/forms/new',
  name: 'survey_admin_forms_edit'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

adminRoutes.route '/surveys/:id/forms/:formId',
  name: 'survey_admin_form_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params
