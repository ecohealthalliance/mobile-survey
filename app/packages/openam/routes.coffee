exposed = FlowRouter.group {}


exposed.route '/login',
 name: 'login'
 action: ->
   BlazeLayout.render "login"
exposed.route '/signup',
 name: 'signup'
 action: ->
   BlazeLayout.render "signup"

Meteor.startup ->
  Meteor.autorun ->
    if Meteor.userId()
      FlowRouter.go '/admin/surveys'
    else
      FlowRouter.go 'login'

# adminRoutes.route '/surveys',
# action: () ->
#   BlazeLayout.render 'layout',
#     main: 'surveys'
#
# adminRoutes.route '/surveys/:id',
# name: 'survey_admin_details'
# action: (params) ->
#   BlazeLayout.render 'layout',
#     main: 'survey_admin'
#     params: params
#
# adminRoutes.route '/surveys/:id/forms',
# name: 'survey_admin_forms'
# action: (params) ->
#   BlazeLayout.render 'layout',
#     main: 'survey_admin'
#     params: params
