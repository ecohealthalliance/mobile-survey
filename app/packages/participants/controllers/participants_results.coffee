sort = sort: {username: 1}

addSubmissions = (participants, collection, query) ->
  participants.find(query, sort)
    .forEach (participant) ->
      collection.insert participant

Template.participant_results.onCreated ->
  @participantId = new ReactiveVar null
  @participant = new ReactiveVar null
  @selectedFormIds = new Meteor.Collection null

  participants = @data.participants

  @participantsWithSubmissions = new Meteor.Collection null
  addSubmissions(participants, @participantsWithSubmissions, {hasSubmitted: true})

  @participantsWithoutSubmissions = new Meteor.Collection null
  addSubmissions(participants, @participantsWithoutSubmissions, {hasSubmitted: {$exists: false}})

Template.participant_results.onRendered ->

  # Select and show results of first user
  @participantId.set @participantsWithSubmissions.findOne({}, sort).objectId

  @autorun =>
    participantId = @participantId.get()
    @participant.set @data.participants.findOne(objectId: participantId)

  @autorun =>
    selectedForms = @selectedFormIds.find().fetch()

Template.participant_results.helpers
  collections: ->
    instance = Template.instance()
    collections = []
    collections.push
      collection: instance.participantsWithSubmissions
      settings:
        name: 'Participants with Submissions'
        key: 'username'
        selectable: true
    collections.push
      collection: instance.participantsWithoutSubmissions
      settings:
        name: 'Participants without Submissions'
        key: 'username'
        selectable: false

    collections

  participantId: ->
    Template.instance().participantId

  participantSelected: ->
    Template.instance().participant.get()

  selectedParticipant: ->
    Template.instance().participant

  username: ->
    Template.instance().participant?.get().username

  formCollection: ->
    forms = new Meteor.Collection null
    _.each Template.instance().data.forms, (form) ->
      forms.insert form.toJSON()
    formCollection =
      collection: forms
      settings:
        name: 'Forms'
        key: 'title'
        selectable: true
        selectAll: true
    [formCollection]

  selectedFormIds: ->
    Template.instance().selectedFormIds

  formSelected: ->
    Template.instance().selectedFormIds.findOne()

  hasSubmissions: ->
    Template.instance().data.participants.findOne hasSubmitted: true
