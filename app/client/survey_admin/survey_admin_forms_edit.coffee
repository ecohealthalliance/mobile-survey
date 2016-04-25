L.Icon.Default.imagePath = '/packages/bevanhunt_leaflet/images'
_map = null # the map instance for the geofence trigger
_geofenceMarker = null # the L.marker object
_mileToMeter = 1609.34
_geofenceShape = null # the L.circle drawing object
_shape =
  color: 'red'
  fillColor: '#f03',
  fillOpacity: 0.5

# resize the map used to define a trigger
resizeMap = () ->
  _map.invalidateSize();

# add marker to the map
addMarker = (latLng) ->
  console.log('_geofenceMarker: ', _geofenceMarker)
  if _geofenceMarker == null
    _geofenceMarker = L.marker(latLng).addTo _map
  else
    _geofenceMarker.setLatLng(latLng)

  if _geofenceShape != null
    _geofenceShape.setLatLng(latLng)
  else
    r = getRadius()
    if r != null
      addShape(latLng, r)

# add shape to the map
addShape = (latLng, r) ->
  radius = r * _mileToMeter
  if _geofenceShape == null
    _geofenceShape = L.circle(latLng, radius, _shape).addTo _map
  else
    _geofenceShape.setLatLng(latLng)
    _geofenceShape.setRadius(radius)

# get the radius
#
# @return [Integer] the user defined radius or null
getRadius = () ->
  val = parseInt($('#radiusTrigger').val(), 10)
  if typeof val == 'undefined' or isNaN(val)
    return null
  return val

# get the coordinates
#
# @return [Array] the user defined coordinates as geoJSON Point or null
getCoordinates = () ->
  if _geofenceShape == null
    return null
  latLng = _geofenceShape.getLatLng()
  return {type: 'Point', coordinates: [latLng.lng, latLng.lat]}

# leaflet event handler for when a map is clicked
onMapClick = (event) ->
  addMarker(event.latlng)
  latLngStr = "[#{event.latlng.lat}, #{event.latlng.lng}]"
  $('#coordinateOrAddressTrigger').val(latLngStr)

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
  'keyup #radiusTrigger, mouseup #radiusTrigger': (event, instance) ->
    r = getRadius()
    if r == null
      return
    if _geofenceMarker != null
      addShape(_geofenceMarker.getLatLng(), r)
  'submit form': (event, instance)->
    event.preventDefault()
    formId = instance.formId
    form = event.currentTarget
    props =
      name: form.name.value
      trigger:
        radius: getRadius()
        loc: getCoordinates()
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
  _map.on 'click', onMapClick
  Template.survey_admin_forms_edit.map = _map

  datetimeTrigger = $('#datetimeTrigger').datetimepicker {format: 'MM/DD/YY hh:mm'}
  datetimeTrigger.data('DateTimePicker').widgetPositioning {vertical: 'bottom', horizontal: 'right'}
