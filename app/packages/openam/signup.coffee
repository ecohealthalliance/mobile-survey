Template.signup.events
  'submit form': (event, instance) ->
    event.preventDefault()

    Meteor.call("registerNewUser", "yursky555@blurg.com", "P@ssw0rd")
