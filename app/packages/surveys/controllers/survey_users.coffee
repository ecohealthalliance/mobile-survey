Template.survey_users.onCreated ->
  @fetched = new ReactiveVar false

Template.survey_users.onRendered ->
  @survey = @data.survey
  @fetched.set false
  if @survey.has 'invitedUsers'
    @users = new Meteor.Collection null
    instance = @
    @survey.getInvitedUsers()
      .then (users) ->
        users.forEach (item) ->
          instance.users.insert item.toJSON()
      .fail (err) ->
        toastr.error err.message
      .always ->
        instance.fetched.set true
  else
    @fetched.set true

Template.survey_users.helpers
  users: ->
    Template.instance().users?.find()

Template.survey_users.events
  'click .remove-user': (event, instance) ->
    user = @
    instance.survey.removeInvitedUser(@objectId)
      .then ->
        instance.users.remove 'objectId': user.objectId
