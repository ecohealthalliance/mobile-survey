Template.survey_admin_users.onCreated ->
  @users = new Meteor.Collection(null)
  @fetched = new ReactiveVar false
Template.survey_admin_users.onRendered ->
  @survey = @data.survey
  @users.find().map (user)=>
    @users.remove user
  @fetched.set(false)
  @survey.relation('invitedUsers').query().find()
    .then (result) =>
      result.forEach (item)=>
        console.log @users
        console.log item.toJSON()
        @users.insert item.toJSON()
      console.log result
    .fail (err)->
      console.error(err)
      toastr.error err.message
    .always =>
      @fetched.set(true)

Template.survey_admin_users.helpers
  fetched: ->
    Template.instance().fetched.get()
  users: ->
    Template.instance().users.find()
