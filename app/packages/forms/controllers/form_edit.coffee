{Survey, Form} = require 'meteor/gq:api'
validator = require 'bootstrap-validator'

_map = null # the map instance for the geofence trigger
_minZoom = 3 # the minimum zoom level of the map
_maxZoom = 13 # the maximum zoom level of the map
_defaultZoom = 3 # the default zoom level of the map
_searchBar = null # onRendered will set this to a typeahead object
_datetimeTrigger = null
_geofenceMarker = null # the L.marker object
_mileToMeter = 1609.34
_geofenceShape = null # the L.circle drawing object
_shape =
  color: 'red'
  fillColor: '#f03',
  fillOpacity: 0.5
# the underscore templates for the typeahead result
_suggestionTemplate = _.template('
  <span class="typeahead-info">
    <%= raw.formattedAddress %>
  </span>')
_typeaheadFooter = _.template('
  <div class="typeahead-footer">
    <div class="row">
      <div class="col-xs-6">
        <span style="margin-left: 10px;">&copy; GoodQuestion</span>
      </div>
      <div class="col-xs-6"></div>
    </div>
  </div>')

# resize the map
resizeMap = () ->
  _map.invalidateSize()

# resets the map
resetMap = () ->
  if _geofenceMarker != null
    _map.removeLayer(_geofenceMarker)
    _geofenceMarker = null
  if _geofenceShape != null
    _map.removeLayer(_geofenceShape)
    _geofenceShape = null

# add marker to the map
#
# @param [Object] latLng, leaflet L.latLng obj
# @param [Boolean] shouldZoom
addMarker = (latLng, shouldZoom) ->
  if _geofenceMarker == null
    _geofenceMarker = L.marker(latLng).addTo _map
  else
    if not _map.hasLayer(_geofenceMarker)
      _map.addLayer(_geofenceMarker)
    _geofenceMarker.setLatLng(latLng)
  setCoordinateBox(latLng)
  addShape(latLng, shouldZoom)

# add shape to the map
#
# @param [Object] latLng, leaflet L.latLng obj
# @param [Boolean] shouldZoom
addShape = (latLng, shouldZoom) ->
  r = getRadius()
  if r != null
    radius = r * _mileToMeter
    if _geofenceShape == null
      _geofenceShape = L.circle(latLng, radius, _shape).addTo _map
    else
      if not _map.hasLayer(_geofenceShape)
        _map.addLayer(_geofenceShape)
      _geofenceShape.setLatLng(latLng)
      _geofenceShape.setRadius(radius)
  if shouldZoom and r != null
    # setView the latLng and calculated zoom
    _map.setView(latLng, radiusToZoomLevel())
  else
    _map.panTo(latLng)
debounceAddShape = _.debounce(addShape, 500)

# get the radius
#
# @return [Number] the user defined radius or null
getRadius = () ->
  val = parseFloat($('#radiusTrigger').val(), 10)
  if typeof val == 'undefined' or isNaN(val)
    return null
  return val

# deterime how far to zoom based on the size of the radius
# @return [Integer] the zoom level
radiusToZoomLevel = () ->
  zoomLevels = [_map.getMaxZoom(), _map.getMinZoom()]
  numberLevels = (zoomLevels[0] - zoomLevels[1]) + 1
  r = getRadius()
  c = 0
  l = null
  while c < numberLevels
    if r == null or r <= 1
      l = zoomLevels[0]
      break
    if c == numberLevels
      l = zoomLevels[1]
      break
    if r <= Math.pow(c,2.75) - 16
      l = (zoomLevels[0] + 1) - c
      break
    c++
  return l

# get the coordinates
#
# @return [Array] the user defined coordinates as geoJSON Point or null
getCoordinates = () ->
  if _geofenceMarker
    latLng = _geofenceMarker.getLatLng()
    latitude: latLng.lat
    longitude: latLng.lng

# set the UI to the L.latLng object
#
# @param [Object] latLng, a leaflet L.latLng object
setCoordinateBox = (latLng) ->
  latLngStr = "[#{latLng.lat}, #{latLng.lng}]"
  $('#coordinateBox').val(latLngStr)
  return

# get the datetime object
#
# @return [Ingeter] timestamp, the unix timestamp
getDatetime = () ->
  return _datetimeTrigger.data('DateTimePicker').date().toISOString()

# perform a http get to geoCode an address
#
# @param [String] q, the query
# @param [Function] cb, the callback to the suggestionGenerator
debounceAddressSearch = _.debounce((q, cb) ->
  Meteor.call('geocode', q, cb)
, 1500)

# generate suggestions for the searchBar
#
# @param [Object] instance, the template instance
# @param [String] query, the query string from the UI
# @param [Function] callback, the callback to the tokenizer
suggestionGenerator = (instance, query, callback) ->
  instance.isAddressSearching.set(true)
  debounceAddressSearch(query, (err, res) ->
    instance.isAddressSearching.set(false)
    if err
      toastr.error(err.message)
      return
    if Object.keys(res).length == 0
      toastr.warning('No results found.')
      callback([])
      return
    if _.isObject(res)
      # the tokenizer expects an array of objects with keys 'label', 'value', we add 'raw' for the _suggestionTemplate
      matches = _.map Object.keys(res), (key) -> {'label': res[key].formattedAddress, 'value': res[key].extra.googlePlaceId, raw: res[key]}
      callback(matches)
  )

# leaflet event handler for when a map is clicked
onMapClick = (event) ->
  if _searchBar.tokenfield('getTokens').length > 0
    # TODO show a sweetalert / bootstrap confirm to confirm clicking on the map when an address is present
    return
  addMarker(event.latlng)

Template.form_edit.onCreated ->
  @fetched = new ReactiveVar false
  @triggerType = new ReactiveVar 'location'
  @isAddressSearching = new ReactiveVar false
  @survey = @data.survey
  @formId = @data.formId
  relation = @survey.relation 'forms'
  query = relation.query()
  instance = @

  # If creating a new form, show form fields
  unless @formId
    instance.fetched.set true
    return

  query.equalTo 'objectId', @data.formId
  query.first().then (form) ->
    instance.form = form
    form.getTrigger().then (trigger) ->
      instance.trigger = trigger
      instance.fetched.set true
  , (form, error) ->
    toastr.error error.message

Template.form_edit.helpers
  form: ->
    Template.instance().form
  trigger: ->
    Template.instance().trigger
  isAddressSearching: ->
    Template.instance().isAddressSearching.get()
  showingTriggers: ->
    Template.instance().showingTriggers.get()
  triggerTypeState: (type) ->
    type == Template.instance().triggerType.get()
  isEditing: ->
    Template.instance().formId

Template.form_edit.events
  'keydown .edit-form': (event, instance) ->
    if event.keyCode == 13
      event.preventDefault()
      event.stopPropagation()
      return

  'click #tabs li a': (event, instance) ->
    type = instance.triggerType
    type.set $(event.currentTarget).data 'type'
    if type.get() == 'location'
      Meteor.defer ->
        resizeMap()

  'click #cancelForm': (event, instance) ->
    # upon canceling, go to the list
    FlowRouter.go("/surveys/#{instance.survey.id}/forms")

  'keyup #searchAddress': (event, instance) ->
    q = getAddress()
    if q == null
      return
    instance.isAddressSearching.set(true)
    debounceAddressSearch(q, instance)

  'keyup #radiusTrigger, mouseup #radiusTrigger': (event, instance) ->
    if _geofenceMarker != null
      debounceAddShape(_geofenceMarker.getLatLng(), true)

  'tokenfield:initialize': (e) ->
    $target = $(e.target)
    $container = $target.closest('.tokenized')
    id = $target.attr('id')
    #$container.find('.tokenized.main').prepend($("#searchIcon"))
    $('#' + id + '-tokenfield').on 'blur', (e) ->
      # only allow tokens
      $container.find('.token-input.tt-input').val("")

  'tokenfield:createtoken': (e) ->
    if e.keyCode == 13 or e.keyCode == 9
      e.preventDefault()
      e.stopPropagation()
      return
    $target = $(e.target)
    tokens = $target.tokenfield('getTokens')
    if tokens.length >= 1
      e.preventDefault()
      return
    $('.twitter-typeahead').hide()

  'tokenfield:removedtoken': (e) ->
    $target = $(e.target)
    tokens = $target.tokenfield('getTokens')
    if tokens.length == 0
      $('.twitter-typeahead').show()
      resetMap()

  'tokenfield:createdtoken': (e) ->
    $target = $(e.target)
    obj = e.attrs
    if not obj.hasOwnProperty('raw')
      $target.tokenfield('setTokens', [])
      toastr.error('Invalid address, please select one from the search results.')
      $('.twitter-typeahead').show()
      return
    latLng = L.latLng(e.attrs.raw.latitude, e.attrs.raw.longitude)
    addMarker(latLng, true)

  'submit form': (event, instance)->
    event.preventDefault()
    form = event.currentTarget
    trigger = null
    # what trigger is active
    type = instance.triggerType.get()
    if type == 'location'
      if not getRadius()
        toastr.error 'Please select a radius.'
        return
      coordinates = getCoordinates()
      if not coordinates
        toastr.error 'Please select a location by entering an address or clicking on map.'
        return
      trigger =
        type: type
        properties:
          radius: getRadius()
        location: coordinates
    if type == 'datetime'
      if not getDatetime()
        toastr.error 'Please select a date and time.'
        return
      trigger =
        type: type
        properties:
          datetime: new Date getDatetime()
    props =
      title: form.name.value
      trigger: trigger

    form = instance.form
    if form
      form.update(props)
        .then ->
          FlowRouter.go "/surveys/#{instance.survey.id}/forms"
        .fail (error) ->
          toastr.error error.message
    else
      instance.survey.addForm(props)
        .then (form) ->
          FlowRouter.go "/surveys/#{instance.survey.id}/forms/#{form.id}"
        .fail (error) ->
          toastr.error error.message

  'click .delete-form': (event, instance) ->
    survey = instance.survey
    survey.getForm(instance.formId)
      .then (form) ->
        form.delete()
      .then ->
        FlowRouter.go "/surveys/#{survey.id}"

Template.form_edit.onRendered ->
  # the map is recreated each time the page is rendered, so clear any old
  # marker/shape
  _geofenceMarker = null
  _geofenceShape = null

  L.Icon.Default.imagePath = '/packages/bevanhunt_leaflet/images'
  CartoDB = L.tileLayer 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    layerName: 'CartoDB'
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'

  mapOptions =
    height: '400px'
    zoomControl: false

    minZoom: _minZoom
    maxZoom: _maxZoom
    zoom: _defaultZoom
    center: L.latLng(39.82, -98.58)
    layers: [CartoDB]

  # create the map
  @autorun =>
    fetched = @fetched.get()
    if fetched
      Meteor.defer =>
        _map = L.map 'map', mapOptions
        _map.addControl L.control.zoom position: 'topright'
        _map.on 'click', onMapClick
        _map.scrollWheelZoom.disable()
        Template.form_edit.map = _map

        _datetimeTrigger = $('#datetimeTrigger').datetimepicker
          format: 'MM/DD/YY hh:mm'
          inline: true
          sideBySide: true
        _datetimeTrigger.data('DateTimePicker').widgetPositioning
          vertical: 'bottom'
          horizontal: 'right'

        instance = @
        _searchBar = $('#searchBar').tokenfield
          typeahead: [
            {hint: false, highlight: true},
            display: (match) ->
              match?.label
            templates:
              suggestion: _suggestionTemplate
              footer: _typeaheadFooter
            source: (query, callback) ->
              suggestionGenerator instance, query, callback
          ]
        @$('.edit-form').validator
          errors:
            minlength: 'Title must be at least 3 characters'

        # update input fields if editing
        if @form and @trigger
          type = @trigger.get 'type'
          @triggerType.set type
          triggerProps = @trigger.get 'properties'
          if type == 'datetime'
            _datetimeTrigger.data('DateTimePicker').date new Date triggerProps.datetime
          else
            location = @trigger.get 'location'
            latLng = L.latLng location.latitude, location.longitude
            addMarker latLng, true
            resizeMap()
