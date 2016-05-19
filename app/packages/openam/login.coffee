# Log out the meteor user if the parse user is not logged in.
Meteor.startup ->
  Accounts.onLogin ->
    interval = window.setTimeout ->
      if not Parse.User.current()
        Meteor.logout()
    , 1000

Template.login.events
  'submit form': (event, instance) ->
    event.preventDefault()

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Parse.User.logIn(email, passw)
      .then ()->
        Meteor.call 'loginUser', email, passw, (err, token) ->
          console.log(token)
          Meteor.loginWithToken token, (err)->
            if err
              toastr.error('Could not log into Meteor')
      .fail (error)->
        console.error('Could not log into Parse.')
        toastr.error('Could not log into Parse.')
        Meteor.logout()
