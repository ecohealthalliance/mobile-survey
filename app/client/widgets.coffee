Template.widget.helpers
  widgetTemplateName: ->
    data = Template.currentData()
    return "widget.#{data.type}"


Template.widget_edit.helpers
  widgetTemplateName: ->
    data = Template.currentData()
    return "widget.#{data.type}.edit"
  isLast: ->
    @_id is Widgets.findOne({}, {sort: order: -1})._id
  isFirst: ->
    @_id is Widgets.findOne({}, {sort: order: 1})._id

Template.widget_edit.events
  'click .up': (event, instance) ->
    event.preventDefault()
    # TODO move up
  'click .down': (event, instance) ->
    event.preventDefault()
    # TODO move down
  'click .x': (event, instance) ->
    Widgets.remove(instance.data._id)
