Template.login.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Meteor.call("loginUser", email, passw, (err, token) ->
      Meteor.loginWithToken(token)
    )
