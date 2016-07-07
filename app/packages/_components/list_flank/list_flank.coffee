Template.list_flank.helpers
  collection: ->
    @collection.find()

Template.list_flank.events
  'click li.selectable': (event, instance) ->
    data = instance.data
    selected = data.selected
    itemId = @item.objectId
    if data.selectMultiple
      if selected.findOne(id: itemId)
        selected.remove id: itemId
      else
        selected.insert id: itemId
    else
      data.selected.set itemId

Template.list_flank_item.helpers
  title: ->
    data = Template.instance().data
    data.item[data.settings.key]
  selected: ->
    itemId = @item.objectId
    selected = @selected
    if @selectMultiple
      selected.findOne id: itemId
    else
      itemId is selected.get()
  selectable: ->
    @settings.selectable
