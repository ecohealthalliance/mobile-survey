Template.list_flank.helpers
  collection: ->
    Template.instance().data.collection.find()
  item: ->
    @[Template.instance().data.item]

Template.list_flank.events
  'click li': (event, instance) ->
    instance.data.selectedId.set @item.objectId

Template.list_flank_item.helpers
  item: ->
    data = Template.instance().data
    data.item[data.key]
  selected: ->
    @item.objectId is Template.instance().data.selectedId.get()
