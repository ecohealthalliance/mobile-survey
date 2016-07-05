Template.participant_results.onCreated ->
  @participantId = new ReactiveVar null

Template.participant_results.helpers
  username: ->
    Template.instance().data.participants.find()?.username
  participantId: ->
    Template.instance().participantId
  participantSelected: ->
    Template.instance().participantId.get()
  participant: ->
    instance = Template.instance()
    participantId = instance.participantId.get()
    instance.data.participants.findOne objectId: participantId
