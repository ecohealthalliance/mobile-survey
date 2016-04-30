Parse = require 'parse'

exports.updateSortOrder = (event, parentObj, relatedObjString) ->
  objId    = $(event.item).data 'id'
  oldOrder = ++event.oldIndex
  newOrder = ++event.newIndex
  relation = parentObj.relation relatedObjString
  query    = relation.query()

  # Get the moved object from Parse server
  query.get(objId).then (obj) ->
    movingUp = obj.get('order') > newOrder
    # Build query to get effected objects in list
    query = relation.query()
    # Do not get the moved object
    query.notEqualTo 'objectId', obj.id
    query.ascending 'order'
    if movingUp
      query.greaterThanOrEqualTo 'order', newOrder
    else
      query.lessThanOrEqualTo 'order', newOrder
      query.greaterThan 'order', oldOrder
    ###
     Run query and increment/decrement order of each obj according to the
     direction the original item was moved. Parse does not allow the each
     method called on queries with sorting
    ###
    query.find().then (effectedObjs) ->
      _.each effectedObjs, (effectedObj) ->
        if movingUp then amount = 1 else amount = -1
        effectedObj.increment 'order', amount
        effectedObj.save()
    # Set new order of mov list item and save
    obj.set 'order', newOrder
    obj.save()
