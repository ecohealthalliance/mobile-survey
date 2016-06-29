Template.participant_list.helpers
  participants: ->
    Template.instance().data.participants.find()

Template.participant_list.events
  'click .remove-user': (event, instance) ->
    user = @
    instance.survey.removeInvitedUser(@objectId)
      .then ->
        instance.users.remove 'objectId': user.objectId
