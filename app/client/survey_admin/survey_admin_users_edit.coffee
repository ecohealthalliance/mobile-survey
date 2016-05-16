Template.survey_admin_users_edit.onRendered ->
  @survey = @data.survey

Template.survey_admin_users_edit.events
  'submit form': (event, instance)->
    event.preventDefault()
    userProps = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    userProps.username = userProps.email
    userProps.password = "changeme"
    console.log userProps
    currentUserSessionToken = Parse.User.current().getSessionToken()
    newUser = null
    query = new Parse.Query(Parse.User)
    query.equalTo("email", userProps.email)
    query.first()
      .then (user)->
        if user
          console.log "happy"
          user
        else
          Parse.User.signUp(userProps.username, userProps.password, userProps)
      .then (user)->
        newUser = user
        Parse.User.become(currentUserSessionToken)
        instance.survey.relation('invitedUsers').add(user)
        instance.survey.save()
      .then ->
        query = new Parse.Query(Parse.Role)
        query.equalTo("name", "user")
        query.first()
      .then (role)->
        role.relation("users").add(newUser)
        role.save()
      .then ->
        toastr.success("User added")
        FlowRouter.go("/admin/surveys/#{instance.survey.id}/users")
      .fail (err)->
        console.error(err)
        toastr.error(err.message)

  'click #cancel': (event, instance) ->
    FlowRouter.go("/admin/surveys/#{instance.survey.id}/users")