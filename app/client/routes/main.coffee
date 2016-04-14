BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: () ->
    FlowRouter.go '/admin/surveys'

FlowRouter.route '/admin/surveys',
  name: 'surveys'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'surveys'

FlowRouter.route '/admin/surveys/:id',
  name: 'survey_details'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/forms',
  name: 'survey_forms'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params

FlowRouter.route '/admin/surveys/:id/users',
  name: 'survey_users'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params
