Meteor.startup ->
  Meteor.autorun ->
    if Meteor.userId()
      FlowRouter.go '/admin/surveys'
    else
      FlowRouter.go 'login'


exposed = FlowRouter.group {}

adminRoutes = FlowRouter.group
  prefix: '/admin'
  name: 'admin'
  triggersEnter: [ ->
    unless Meteor.loggingIn() or Meteor.userId()
      route = FlowRouter.current()
      FlowRouter.go 'login'
  ]


exposed.route '/login',
 name: 'login'
 action: ->
   BlazeLayout.render "login"


adminRoutes.route '/signup',
  name: 'signup'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'signup'
      params: params
