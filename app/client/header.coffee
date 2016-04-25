Template.header.events
  'click #logout': (event, instance) ->
    event.preventDefault()
    Meteor.logout()
