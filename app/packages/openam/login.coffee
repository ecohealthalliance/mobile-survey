Template.login.events
  'submit form': (event, instance) ->
    event.preventDefault()

    # form = event.currentTarget
    # console.log form.username.value.trim()
    # console.log form.password.value.trim()

    Meteor.call("loginUser", "yursky555@blurg.com", "P@ssw0rd", (err, token) ->
      Meteor.loginWithToken(token)
    )
