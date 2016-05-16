Template.login.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Meteor.call 'loginUser', email, passw, (err, token) ->
      Meteor.loginWithToken token, (err)->
        if err
          toastr.error('Could not log into Meteor')
          return
        Parse.User.logIn(email, passw)
          .then ()->
            console.log(Parse.User.current())
          .fail (error)->
            toastr.error('Could not log into Parse.')
            Meteor.logout()
