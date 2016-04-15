BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: () ->
    FlowRouter.go '/admin/surveys'

FlowRouter.route '/admin/surveys',
  action: () ->
    BlazeLayout.render 'layout',
      main: 'surveys'

FlowRouter.route '/admin/surveys/:id',
  name: 'survey_admin_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/forms',
  name: 'survey_admin_forms'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/users',
  name: 'survey_admin_users'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/forms/new',
  name: 'survey_admin_forms_new'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/forms/:formId',
  name: 'survey_admin_form_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params
