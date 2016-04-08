Template.widget.helpers
  widgetTemplateName: ->
    data = Template.currentData()
    return "widget.#{data.type}"

Template.widget_edit.helpers
  widgetTemplateName: ->
    data = Template.currentData()
    return "widget.#{data.type}.edit"

Template.widget_edit.events
  'click .delete': (event, instance) ->
    Widgets.remove(instance.data._id)
