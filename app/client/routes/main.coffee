BlazeLayout.setRoot('body')

FlowRouter.route '/',
  action: () ->
    FlowRouter.go '/admin/surveys'

FlowRouter.route '/admin/surveys',
  action: () ->
    BlazeLayout.render 'layout',
      main: 'surveys'

FlowRouter.route '/admin/surveys/:id',
  action: ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'

FlowRouter.route '/admin/surveys/:id/:page',
  action: ->
    BlazeLayout.render 'layout',
      main: 'survey_admin'
