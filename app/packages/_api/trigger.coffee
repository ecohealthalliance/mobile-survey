Trigger = Parse.Object.extend 'Trigger',
  create: (props, form) ->
    trigger = @
    @setProperties props
    @save()
      .then ->
        trigger.addToForm(form)
      .then ->
        trigger

  setProperties: (props) ->
    type = props.type
    @set 'type', type
    properties = props.properties
    if type == 'location'
      @set 'location', new Parse.GeoPoint props.location
      delete props.location
    @set 'properties', properties

  update: (props) ->
    @setProperties(props)
    @save()
      .then (trigger) ->
        trigger

  addToForm: (form) ->
    relation = form.relation 'triggers'
    relation.add @
    form.save()
      .then =>
        @

  delete: (deleted = true) ->
    @set 'deleted', deleted
    @save()

  undelete: ->
    @delete(false)

module.exports = Trigger
