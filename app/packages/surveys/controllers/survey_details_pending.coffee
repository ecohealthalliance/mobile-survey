activate = require '../imports/activation'

Template.survey_details_pending.onCreated ->
  @active = new ReactiveVar @data.survey.get 'active'
  @activating = new ReactiveVar false

Template.survey_details_pending.helpers
  forms: ->
    Template.instance().data.forms?.find {}, sort: {order: 1}

  activating: ->
    Template.instance().activating.get()

Template.survey_details_pending.events
  'click .activate': (event, instance)->
    activate instance
