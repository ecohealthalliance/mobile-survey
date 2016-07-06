Template.participant_results.onCreated ->
  @participantId = new ReactiveVar null
  @participant = new ReactiveVar null
  @selectedFormIds = new Meteor.Collection null

Template.participant_results.onRendered ->
  @autorun =>
    participantId = @participantId.get()
    @participant.set @data.participants.findOne(objectId: participantId)

  @autorun =>
    selectedForms = @selectedFormIds.find().fetch()

Template.participant_results.helpers
  collections: ->
    collections = []
    # Users with submissions
    participants = Template.instance().data.participants.find hasSubmitted: true
    participantsWithSubmissions = new Meteor.Collection null
    participants.forEach (participant) ->
      participantsWithSubmissions.insert participant
    collections.push
      collection: participantsWithSubmissions
      settings:
        name: 'Participants with Submissions'
        key: 'username'
        selectable: true

    # Users without submissions
    participants = Template.instance().data.participants.find hasSubmitted: {$exists: false}
    participantsWithoutSubmissions = new Meteor.Collection null
    participants.forEach (participant) ->
      participantsWithoutSubmissions.insert participant
    collections.push
      collection: participantsWithoutSubmissions
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
    [formCollection]

  selectedFormIds: ->
    Template.instance().selectedFormIds

  hasSubmissions: ->
    Template.instance().data.participants.findOne hasSubmitted: true
