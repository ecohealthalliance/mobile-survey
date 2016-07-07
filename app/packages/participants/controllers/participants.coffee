Template.participants.onCreated ->
  @survey = @data.survey
  @participants= new Meteor.Collection null
  @fetched = new ReactiveVar false

Template.participants.onRendered ->
  @survey = @data.survey
  @fetched.set false
  @users = new Meteor.Collection null
  instance = @
  _participants = null
  formIds = null
  submissionUserIds = null
  _submissions = null
  # Fetch all the users until we fully implement Invited Users
  instance.survey.getForms()
    .then (forms) ->
      instance.forms = forms
      formIds = _.map forms, (form) ->
        form.id
      query = new Parse.Query Parse.User
      query.find()
    .then (participants) ->
      _participants = participants
      participants.forEach (participant) ->
        _participant = participant.toJSON()
        instance.participants.insert _participant
    .then ->
      instance.participants.find().forEach (participant) ->
        _participant = new Parse.User()
        _participant.id = participant.objectId
        query = new Parse.Query 'Submission'
        query.containedIn 'formId', formIds
        query.equalTo 'userId', _participant
        query.first()
          .then (submission) ->
            if submission
              instance.participants.update {_id: participant._id}, {$set: {hasSubmitted: true}}
          .fail (err) ->
            console.log err
    .fail (err) ->
      toastr.error err.message
    .always ->
      instance.fetched.set true

Template.participants.helpers
  participants: ->
    Template.instance().participants
  forms: ->
    Template.instance().forms
