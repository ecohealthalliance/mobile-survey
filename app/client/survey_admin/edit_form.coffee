_map = null # the map instance for the geofence trigger

# resize the map used to define a trigger
resizeMap = () ->
  _map.invalidateSize();


Template.edit_form.onCreated ->
  @survey = Template.parentData().survey
  @form = @data.form

Template.edit_form.helpers
  form: ->
    Template.instance().form

Template.edit_form.events
  'click #toggleTrigger': (event, instance) ->
    if $('.trigger-container').is(':visible')
      $('.trigger-container').hide()
    else
      $('.trigger-container').show()
      resizeMap()
  'click #cancelForm': (event, instance) ->
    # upon canceling the edit_form, go to the list
    # TODO possibly make a separate view 'create_form' that will only create the initial form upon form submission and allow the action to be canceled
    # TODO the most recent form is not displayed upon navigating back to the list
    FlowRouter.go("""/admin/surveys/#{instance.survey._id}/forms""")
  'submit form': (event, instance)->
    event.preventDefault()
    formObj = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    formObj._id = instance.form._id
    # TODO object validation
    Meteor.call 'updateForm', formObj, (error, formId)->
      if error
        toastr.error('Error')
      else
        FlowRouter.go("""/admin/surveys/#{FlowRouter.getParam('id')}/forms""")

Template.edit_form.onRendered ->
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
  Template.edit_form.map = _map

  datetimeTrigger = $('#datetimeTrigger').datetimepicker {format: 'MM/DD/YY hh:mm'}
  datetimeTrigger.data('DateTimePicker').widgetPositioning {vertical: 'bottom', horizontal: 'right'}
