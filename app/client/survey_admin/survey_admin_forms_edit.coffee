L.Icon.Default.imagePath = '/packages/bevanhunt_leaflet/images'
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
  <span class="typeahead-code">
    <%= raw.place_id %>
  </span>
  <br/>
  <span class="typeahead-info">
    <%= raw.display_name %>
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
  if _geofenceShape != null
    _map.removeLayer(_geofenceShape)

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
  if _geofenceShape == null
    return null
  latLng = _geofenceShape.getLatLng()
  return {type: 'Point', coordinates: [latLng.lng, latLng.lat]}

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

# returns the active trigger type or null
#
# @return [String] the type of trigger 'location' or 'datetime'
getActiveTrigger = () ->
  type = null
  if ($('.trigger-container').is(':visible'))
    active = $('#tabs li.active a').attr('href')
    if active == '#location'
      type = 'location'
    if active == '#datetime'
      type = 'datatime'
  return type

# perform a http get to geoCode an address
#
# @param [String] q, the query
# @param [Function] cb, the callback to the suggestionGenerator
debounceAddressSearch = _.debounce((q, cb) ->
  url = encodeURI('http://nominatim.openstreetmap.org/search/'+q)
  Meteor.http.get(url, {params: {format: 'json', limit: 10}}, cb)
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
    if res.statusCode != 200
      toastr.error('Network Error: ' + res.statusCode)
      return
    if _.isArray(res.data)
      # the tokenizer expects an array of objects with keys 'label', 'value', we add 'raw' for the _suggestionTemplate
      matches = _.map res.data, (loc) -> {'label': loc.display_name, 'value': loc.place_id, raw: loc}
      if Object.keys(matches).length == 0
        toastr.warning('No results found.')
        return
      callback(matches)
  )

# leaflet event handler for when a map is clicked
onMapClick = (event) ->
  if _searchBar.tokenfield('getTokens').length > 0
    # TODO show a sweetalert / bootstrap confirm to confirm clicking on the map when an address is present
    return
  addMarker(event.latlng)

Template.survey_admin_forms_edit.onCreated ->
  @isAddressSearching = new ReactiveVar(false)
  @surveyId = @data.surveyId
  @formId = @data.formId
  @form = new ReactiveVar(null)
  @subscribe 'form', @formId,
    onReady: () =>
      form = Forms.findOne _id: @formId
      @form.set(form)

Template.survey_admin_forms_edit.helpers
  form: ->
    Template.instance().form.get()
  isAddressSearching: ->
    Template.instance().isAddressSearching.get()

Template.survey_admin_forms_edit.events
  'keydown .edit-form': (event, instance) ->
    if event.keyCode == 13
      event.preventDefault()
      event.stopPropagation()
      return
  'click #toggleTrigger': (event, instance) ->
    if $('.trigger-container').is(':visible')
      $('.trigger-container').hide()
    else
      $('.trigger-container').show()
      resizeMap()
  'click #cancelForm': (event, instance) ->
    # upon canceling, go to the list
    FlowRouter.go("/admin/surveys/#{instance.surveyId}/forms")
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
    $('#' + id + '-tokenfield').on('blur', (e) ->
      # only allow tokens
      $container.find('.token-input.tt-input').val("")
    )
    return
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
    latLng = L.latLng(e.attrs.raw.lat, e.attrs.raw.lon)
    addMarker(latLng, true)
  'submit form': (event, instance)->
    event.preventDefault()
    formId = instance.formId
    form = event.currentTarget
    trigger = null
    # what trigger is active
    type = getActiveTrigger()
    if type == 'location'
      trigger =
        type: type
        radius: getRadius()
        loc: getCoordinates()
    if type == 'datetime'
      trigger =
        type: type
        datetime: getDatetime()
    props =
      name: form.name.value
      trigger: trigger
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
  # the map is recreated each time the page is rendered, so clear any old
  # marker/shape
  _geofenceMarker = null
  _geofenceShape = null

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
  _map = L.map 'map', mapOptions
  _map.addControl L.control.zoom {position: 'bottomright'}
  _map.on 'click', onMapClick
  Template.survey_admin_forms_edit.map = _map

  _datetimeTrigger = $('#datetimeTrigger').datetimepicker {format: 'MM/DD/YY hh:mm'}
  _datetimeTrigger.data('DateTimePicker').widgetPositioning {vertical: 'bottom', horizontal: 'right'}

  instance = this
  _searchBar = $('#searchBar').tokenfield({
    typeahead: [{hint: false, highlight: true}, {
      display: (match) ->
        if _.isUndefined(match)
          return
        return match.label
      templates:
        suggestion: _suggestionTemplate
        footer: _typeaheadFooter
      source: (query, callback) ->
        suggestionGenerator(instance, query, callback)
        return
    }]
  })

  @autorun =>
    # populate custom form objects when our form is ready
    form = @form.get()
    if form and form.trigger
      $('.trigger-container').show()
      $('#tabs a[href="#'+form.trigger.type+'"]').tab('show')
      if form.trigger.type == 'datetime'
        _datetimeTrigger.data('DateTimePicker').date(new Date(form.trigger.datetime))
      else
        $('#radiusTrigger').val(form.trigger.radius)
        latLng = L.latLng(form.trigger.loc.coordinates[1], form.trigger.loc.coordinates[0])
        addMarker(latLng, true)
        resizeMap()
