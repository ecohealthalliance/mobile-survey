Template.header.events
  'click #logout': (event, instance) ->
    event.preventDefault()
    Parse.User.logOut().then ->
      Meteor.logout()
