allItemsSelected = (instance) ->
  instanceData = instance.data
  instanceData.selected.find().count() is instanceData.collection.find().count()

Template.list_flank_sub_list.onCreated ->
  @allItemsSelected = new ReactiveVar false

Template.list_flank_sub_list.helpers
  collection: ->
    @collection.find()

  allItemsSelected: ->
    Template.instance().allItemsSelected.get()

Template.list_flank_sub_list.events
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

    instance.allItemsSelected.set allItemsSelected(instance)

  'click .select-all': (event, instance) ->
    selected = instance.data.selected
    collection = @collection.find()
    _allItemsSelected = instance.allItemsSelected
    if allItemsSelected(instance)
      selected.remove {}
      _allItemsSelected.set false
    else
      collection.forEach (item) ->
        obj = id: item.objectId
        selected.upsert obj, obj
      _allItemsSelected.set true

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