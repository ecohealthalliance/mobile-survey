Template.signup.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Meteor.call("registerNewUser", email, passw, (err, res) ->
      if err
        toastr.error("OpenAM Error: " + err.message)
        console.log err, res
        return
      # Create Meteor user
      meteorId = Accounts.createUser(
        email: email
        password: passw
      , (err)->
        if err
          toastr.error("Meteor Error: " + err.message)
          return
        console.log Parse.User.current()
        # Create Parse User
        parseUser = new Parse.User()
        parseUserData =
          username: email
          password: passw
          email   : email
          meteorId: meteorId
          role    : 'admin'
        currentUserSessionToken = Parse.User.current().getSessionToken()
        parseUser.signUp(parseUserData)
          .then ->
            Parse.User.become(currentUserSessionToken)
          .then ->
            query = new Parse.Query(Parse.Role)
            query.equalTo("name", "admin")
            query.first()
          .then (adminRole)->
            console.log Parse.User.current()
            adminRole.relation("users").add(parseUser)
            adminRole.save()
          .then ->
            form.reset()
          .fail (err)->
            toastr.error("Parse Error: " + err.message)
      )
    )
