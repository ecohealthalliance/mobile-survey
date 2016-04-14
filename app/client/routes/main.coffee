BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: () ->
    FlowRouter.go '/admin/surveys'

FlowRouter.route '/admin/surveys',
  action: () ->
    BlazeLayout.render 'layout',
      main: 'surveys'

FlowRouter.route '/admin/surveys/:id',
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
      params: params
