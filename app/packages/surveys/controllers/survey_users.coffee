Template.survey_users.onCreated ->
  @fetched = new ReactiveVar false
Template.survey_users.onRendered ->
  @survey = @data.survey
  @fetched.set false
  if @survey.has 'invitedUsers'
    @users = new Meteor.Collection(null)
    @survey.relation('invitedUsers').query().find()
      .then (result) =>
        result.forEach (item)=>
          @users.insert item.toJSON()
      .fail (err)->
        toastr.error err.message
      .always =>
        @fetched.set true
  else
    @fetched.set true

Template.survey_users.helpers
  users: ->
    Template.instance().users?.find()
