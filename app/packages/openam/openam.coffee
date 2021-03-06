'use strict'


open_AM_url = Meteor.settings.private.open_AM_url


Future = Npm.require 'fibers/future'

initiateAdminAuthentication = (callback) ->
  initiateAuthentication Meteor.settings.private.open_AM_admin, Meteor.settings.private.open_AM_password, (result) ->
    callback(result)

initiateAuthentication = (email, password, callback) ->
  #in order to start making requests to the OpenAM API we first need to get a base request framework and token
  Meteor.http.call 'POST',
    "#{open_AM_url}/openam/json/authenticate?Content-Type=application/json",
    (err, result) ->
      #using the returned framework as a base - set the username/password of the user we want to login as
      result.data.callbacks[0].input[0].value = email
      result.data.callbacks[1].input[0].value = password
      callback(result.data)

authenticate = (data, callback) ->
  authData = {}
  authData.data = data
  Meteor.http.call 'POST',
    "#{open_AM_url}/openam/json/authenticate?Content-Type=application/json"
    authData,
    (err, result) ->
      requestBody = {}
      headers = {}
      headers["Content-Type"] = "application/json"
      headers["iplanetDirectoryPro"] = result.data.tokenId
      console.log err if err
      requestBody.headers = headers
      callback(requestBody)


Meteor.methods
  registerNewUser: (email, password) ->
    @unblock()
    future   = new Future()
    callback = future.resolver()
    initiateAdminAuthentication (authData) ->
      authenticate authData, (userData) ->
        userData.data =
          username: email
          userpassword: password
          mail: email
        # create the user in OpenAM
        Meteor.http.call 'POST',
          "#{open_AM_url}/openam/json/users/?_action=create",
          # headers,
          userData,
          (args...) ->
            # Create Meteor user
            Accounts.createUser
              email: email
              password: password
            user = Accounts.findUserByEmail(email)
            meteorId = user._id
            callback(null, meteorId)
    future.wait()
  loginUser: (email, password) ->
    @unblock()
    future = new Future()
    initiateAuthentication email, password, (authData) ->
      authenticate authData, (userData) ->
        # Even though actual authentication takes place on the OpenAM server, we
        # will also log the user in locally to setup the base session. That is why
        # it is important to store the current password in the local db as well.
        tokenObject =
          token: userData.headers.iplanetDirectoryPro
          when: new Date
        user = Accounts.findUserByEmail(email)
        unless user
          Accounts.createUser { email: email, password: password }
          user = Accounts.findUserByEmail(email)
        if tokenObject.token
          Accounts._insertLoginToken(user._id, tokenObject)
          future.return(tokenObject.token)
        else
          future.return(null)
    future.wait()

  changeUserPassword: (currentPassword, newPassword) ->
    @unblock()
    # make sure that we change the password in both OpenAM and in the Meteor db
    # (even thought we don't use the local password for anything...)
    console.log 'implement this'

  logoutUser: () ->
    @unblock()
    Accounts.logout()
    #logout of openAM also
