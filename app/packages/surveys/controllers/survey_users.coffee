Template.survey_users.onCreated ->
  @users = new Meteor.Collection(null)
  @fetched = new ReactiveVar false
Template.survey_users.onRendered ->
  @survey = @data.survey
  @users.find().map (user)=>
    @users.remove user
  @fetched.set(false)
  @survey.relation('invitedUsers').query().find()
    .then (result) =>
      result.forEach (item)=>
        @users.insert item.toJSON()
    .fail (err)->
      toastr.error err.message
    .always =>
      @fetched.set(true)

Template.survey_users.helpers
  users: ->
    Template.instance().users.find()
