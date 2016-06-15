{ setAdminACL, setUserACL, getRole } = require 'meteor/gq:helpers'

Template.survey_user_edit.onCreated ->
  @survey = @data.survey
  @users = new Meteor.Collection null
  instance = @
  @survey.getInvitedUsers()
    .then (users) ->
      _.each users, (user) ->
        instance.users.insert user.toJSON()

Template.survey_user_edit.events
  'submit form': (event, instance)->
    event.preventDefault()
    userProps = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    userProps.username = userProps.email
    userProps.password = "changeme"
    currentUserSessionToken = Parse.User.current().getSessionToken()
    newUser = null
    survey = instance.survey
    query = new Parse.Query(Parse.User)
    query.equalTo("email", userProps.email)
    query.first()
      .then (user)->
        if user
          newUser = user
        else
          user = new Parse.User()
          setAdminACL(user)
            .then ->
              user.set 'username', userProps.username
              user.set 'email', userProps.username
              user.set 'password', userProps.password
              user.set 'role', 'user'
              user.signUp()
      .then (user)->
        if user then newUser = user
        Parse.User.become currentUserSessionToken
      .then ->
        survey.relation('invitedUsers').add newUser
        survey.save()
      .then ->
        getRole('user')
      .then (role) ->
        role.relation("users").add newUser
        role.save()
      .then ->
        if instance.users.findOne('objectId': newUser.id)
          email = newUser.get 'email'
          toastr.warning "#{email} has already been added to the survey"
        else
          toastr.success "User added"
        FlowRouter.go "/surveys/#{survey.id}/users"
      .fail (err)->
        toastr.error(err.message)

  'click #cancel': (event, instance) ->
    FlowRouter.go("/surveys/#{instance.survey.id}/users")
