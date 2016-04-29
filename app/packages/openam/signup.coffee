Template.signup.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Meteor.call("registerNewUser", email, passw, (err, res) ->
      unless err
        form.reset()
    )
