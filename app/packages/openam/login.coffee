# Log out the meteor user if the parse user is not logged in.
parse_logging_in = false
Meteor.startup ->
  Accounts.onLogin ->
    retries = 30
    interval = window.setInterval ->
      if parse_logging_in
        retries -= 1
        if retries == 0
          console.error("Parse login did not complete.")
          Meteor.logout()
          window.clearInterval(interval)
      else
        if not Parse.User.current()
          Meteor.logout()
        window.clearInterval(interval)
    , 1000

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
        parse_logging_in = true
        Parse.User.logIn(email, passw)
          .then ()->
            console.log(Parse.User.current())
          .fail (error)->
            toastr.error('Could not log into Parse.')
            Meteor.logout()
          .always ->
            parse_logging_in = false
