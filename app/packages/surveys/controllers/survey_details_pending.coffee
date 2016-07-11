Template.survey_details_pending.onCreated ->
  @active = new ReactiveVar @data.survey.get 'active'
  @activating = new ReactiveVar false

Template.survey_details_pending.helpers
  description: ->
    Template.instance().data.surveyDetails.get().description

  forms: ->
    Template.instance().data.forms?.find {}, sort: {order: 1}

  inactive: ->
    not Template.instance().active.get()

  activateButtonText: ->
    if Template.instance().active.get() then "Deactivate" else "Activate"

  activateButtonClass: ->
    if Template.instance().active.get() then "mdi-arrow-down-bold-circle-outline" else "mdi-arrow-up-bold-circle-outline"

  activating: ->
    Template.instance().activating.get()

Template.survey_details_pending.events
  'click .activate': (event, instance)->
    activeState = instance.active
    activeState.set not activeState.get()
    props =
      active: activeState.get()
    instance.data.survey.save(props)
      .then (survey) ->
        instance.activating.set true
        survey.setUserACL(activeState.get())
      .then ->
        instance.activating.set false
        instance.data.surveyState.set activeState.get()
        state = (if activeState.get() then "activated" else "deactivated")
        toastr.success("You have " + state + " your survey.")
      .fail (error) ->
        toastr.error error.message
