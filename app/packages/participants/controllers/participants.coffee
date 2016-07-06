Template.participants.onCreated ->
  @survey = @data.survey
  @participants= new Meteor.Collection null
  @fetched = new ReactiveVar false

Template.participants.onRendered ->
  @survey = @data.survey
  @fetched.set false
  if @survey.has 'invitedUsers'
    @users = new Meteor.Collection null
    instance = @
    # @survey.getInvitedUsers()
    # Fetch all the users until we fully implement Invited Users
    query = new Parse.Query Parse.User
    formIds = null
    query.find()
      .then (participants) ->
      #   instance.survey.getForms()
      # .then (forms) ->
      #   formIds = _.map forms, (form) ->
      #     form.id
      #   console.log formIds
        participants.forEach (participant) ->
          instance.participants.insert participant.toJSON()
      .fail (err) ->
        toastr.error err.message
      .always ->
        instance.fetched.set true
  else
    @fetched.set true

Template.participants.helpers
  participants: ->
    Template.instance().participants
