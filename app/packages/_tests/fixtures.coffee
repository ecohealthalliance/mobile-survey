do ->

  'use strict'

  Meteor.methods

    resetFixture: ->
      # Reset the local Meteor+Parse data, grant yourself write permissions
      if Meteor.settings.public.parseServerUrl.match(/localhost|127\.0\.0\.1/)
        console.log("Resetting the local database...")
        # Reset the local Meteor database (Note: logs the user out)
        Package['xolvio:cleaner'].resetDatabase()
        # Create Parse User
        parseUser = new Parse.User()
        parseUserData =
          username: 'yursky555@blurg.com'
          password: 'P@ssw0rd'
          email   : 'yursky555@blurg.com'
          role    : 'admin'
        parseUser.signUp(parseUserData)
          .fail (err)->
            toastr.error("Parse Error: " + err.message)
      else
        console.warn 'The Parse database is not local, we do not reset it.'
