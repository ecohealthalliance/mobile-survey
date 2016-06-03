{ setAdminACL, setUserACL } = require 'meteor/gq:helpers'

Template.survey_user_edit.onRendered ->
  @survey = @data.survey

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
          user
        else
          user = new Parse.User()
          setAdminACL(user)
            .then ->
              user.set 'username', userProps.username
              user.set 'email', userProps.username
              user.set 'password', userProps.password
              user.signUp()
      .then (user)->
        newUser = user
        Parse.User.become(currentUserSessionToken)
      .then ->
        survey.relation('invitedUsers').add(newUser)
        setUserACL survey, newUser
        survey.save()
      .then ->
        query = new Parse.Query Parse.Role
        query.equalTo "name", "user"
        query.first()
      .then (role)->
        role.relation("users").add(newUser)
        role.save()
      .then ->
        toastr.success("User added")
        FlowRouter.go("/admin/surveys/#{survey.id}/users")
      .fail (err)->
        console.error(err)
        toastr.error(err.message)

  'click #cancel': (event, instance) ->
    FlowRouter.go("/admin/surveys/#{instance.survey.id}/users")
