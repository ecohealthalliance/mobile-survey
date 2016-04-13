BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: () ->
    BlazeLayout.render 'layout',
      main: 'container'

FlowRouter.route '/admin/surveys',
  action: () ->
    BlazeLayout.render 'layout',
      main: 'surveys'

FlowRouter.route '/admin/surveys/:id',
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'survey'
      params: params
