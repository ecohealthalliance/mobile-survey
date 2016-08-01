Template.forms.onCreated ->
  @fetched = new ReactiveVar false
  @participants = new Meteor.Collection null
  @survey = @data.survey
  instance = @

  @survey.getForms(true)
    .then (forms) ->
      instance.forms = forms
      query = new Parse.Query Parse.User
      query.find()
    .then (participants) ->
      _.each participants, (participant) ->
        instance.participants.insert participant.toJSON()
      instance.fetched.set true

Template.forms.helpers
  forms: ->
    Template.instance().forms
  participants: ->
    Template.instance().participants
