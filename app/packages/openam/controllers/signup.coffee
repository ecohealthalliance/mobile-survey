Template.signup.onCreated ->
  @signingUp = new ReactiveVar false

Template.signup.helpers
  isSigningUp: ->
    Template.instance().signingUp.get()

Template.signup.events
  'submit form': (event, instance) ->
    event.preventDefault()
    signingUp = instance.signingUp
    signingUp.set true

    form = event.currentTarget
    email = form.username.value.trim()
    passw = form.password.value.trim()

    Meteor.call 'registerNewUser', email, passw, (err, meteorId) ->
      if err
        toastr.error('OpenAM Error: ' + err.message)
        console.log err, meteorId
        return
      # Create Parse User
      parseUser = new Parse.User()
      parseUser.set("username", email)
      parseUser.set("password", passw)
      parseUser.set("email", email)
      parseUser.set("meteorId", meteorId)
      parseUser.set("role", "admin")
      currentUserSessionToken = Parse.User.current().getSessionToken()
      parseUser.signUp(null)
        .then ->
          Parse.User.become(currentUserSessionToken)
        .then ->
          query = new Parse.Query(Parse.Role)
          query.equalTo("name", "admin")
          query.first()
        .then (adminRole)->
          adminRole.relation("users").add(parseUser)
          adminRole.save()
        .then ->
          form.reset()
          toastr.success "#{email} has been added as an admin"
          signingUp.set false
        .fail (err)->
          toastr.error err.message
