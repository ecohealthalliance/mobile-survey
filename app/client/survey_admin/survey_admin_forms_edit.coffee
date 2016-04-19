_map = null # the map instance for the geofence trigger

# resize the map used to define a trigger
resizeMap = () ->
  _map.invalidateSize();

Template.survey_admin_forms_edit.onCreated ->
  @surveyId = @data.surveyId
  @formId = @data.formId
  @subscribe 'form', @formId

Template.survey_admin_forms_edit.helpers
  form: ->
    Forms.findOne _id: Template.instance().formId

Template.survey_admin_forms_edit.events
  'click #toggleTrigger': (event, instance) ->
    if $('.trigger-container').is(':visible')
      $('.trigger-container').hide()
    else
      $('.trigger-container').show()
      resizeMap()
  'click #cancelForm': (event, instance) ->
    # upon canceling, go to the list
    FlowRouter.go("/admin/surveys/#{instance.surveyId}/forms")
  'submit form': (event, instance)->
    event.preventDefault()
    formId = instance.formId
    form = event.currentTarget
    props =
      name: form.name.value
    if formId
      Meteor.call 'editForm', formId, props, (error)->
        if error
          toastr.error 'Error'
        else
          FlowRouter.go "/admin/surveys/#{instance.surveyId}/forms"
    else
      Meteor.call 'createForm', instance.surveyId, props, (error, formId)->
        if error
          toastr.error 'Error'
        else
          FlowRouter.go "/admin/surveys/#{instance.surveyId}/forms/#{formId}"

Template.survey_admin_forms_edit.onRendered ->
  CartoDB = L.tileLayer 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    layerName: 'CartoDB'
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'

  mapOptions =
    height: '400px'
    zoomControl: false
    zoom: 3
    center: L.latLng(39.82, -98.58)
    layers: [CartoDB]

  _map = L.map 'map', mapOptions
  _map.addControl L.control.zoom {position: 'bottomright'}
  Template.survey_admin_forms_edit.map = _map

  datetimeTrigger = $('#datetimeTrigger').datetimepicker {format: 'MM/DD/YY hh:mm'}
  datetimeTrigger.data('DateTimePicker').widgetPositioning {vertical: 'bottom', horizontal: 'right'}
