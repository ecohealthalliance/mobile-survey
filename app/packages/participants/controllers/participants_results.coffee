Template.participant_results.onCreated ->
  @participantId = new ReactiveVar null
  @participant = new ReactiveVar null

Template.participant_results.onRendered ->
  @autorun =>
    participantId = @participantId.get()
    @participant.set @data.participants.findOne(objectId: participantId)

Template.participant_results.helpers
  participantId: ->
    Template.instance().participantId

  participantSelected: ->
    Template.instance().participant.get()

  selectedParticipant: ->
    Template.instance().participant

  username: ->
    Template.instance().participant?.get().username
