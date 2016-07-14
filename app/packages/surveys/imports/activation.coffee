###
  Toggles the activation state of a survey based on the 'active' ReactiveVar
  on the instance
  @param [Object] instance, Blaze instance
###
activate = (instance) ->
  activeState = instance.active
  activeState.set not activeState.get()
  props =
    active: activeState.get()
  instance.activating.set true
  instance.data.survey.save(props)
    .then (survey) ->
      instance.activating.set false
      instance.data.surveyState.set activeState.get()
      state = (if activeState.get() then "activated" else "deactivated")
      toastr.success("You have " + state + " your survey.")
    .fail (error) ->
      toastr.error error.message


module.exports = activate
