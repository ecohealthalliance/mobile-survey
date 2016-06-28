# Log out the meteor user if the parse user is not logged in.
Meteor.startup ->
  Accounts.onLogin ->
    interval = window.setTimeout ->
      if not Parse.User.current()
        Meteor.logout()
    , 1000

Template.login.onCreated ->
  @loggingIn = new ReactiveVar false

Template.login.helpers
  isLoggingIn: ->
    Template.instance().loggingIn.get()

Template.login.events
  'submit form': (event, instance) ->
    event.preventDefault()

    loggingIn = instance.loggingIn
    loggingIn.set true

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Parse.User.logIn(email, passw)
      .then (user)->
        query = new Parse.Query Parse.Role
        query.equalTo 'name', 'admin'
        query.equalTo 'users', Parse.User.current()
        query.first()
          .then (adminRole) ->
            if adminRole
              Meteor.call 'loginUser', email, passw, (err, token) ->
                Meteor.loginWithToken token, (err)->
                  if err
                    toastr.error 'Could not log into Meteor'
                  loggingIn.set false
            else
              toastr.error 'User Not Authorized'
              Parse.User.logOut()
              loggingIn.set false

      .fail (error)->
        toastr.error 'Could not log into Parse.'
        Meteor.logout()
        loggingIn.set false
