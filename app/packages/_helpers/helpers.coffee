###
  Updates the order property of Parse objects after the position
  of an object changes using sortablejs
  @param [Object] event, Event triggered by sort
  @param [Object] parentObj, Parent Parse object of sorted object
  @param [String] relatedObjString, property of parenObj containing relation
###
updateSortOrder = (event, parentObj, relatedObjString) ->
  objectId = $(event.item).data 'id'
  oldOrder = ++event.oldIndex
  newOrder = ++event.newIndex
  relation = parentObj.relation relatedObjString
  query    = relation.query()

  # Get the moved object from Parse server
  query.get(objectId).then (obj) ->
    movingUp = obj.get('order') > newOrder
    # Build query to get effected objects in list
    query = relation.query()
    # Do not get the moved object
    query.notEqualTo 'objectId', obj.id
    query.ascending 'order'
    if movingUp
      query.greaterThanOrEqualTo 'order', newOrder
      query.lessThanOrEqualTo 'order', oldOrder
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

###
  Accpets an array of Parse objects and returns a Meteor Collection
  of documents containing the Parse object's attributes and id
  @param [Array]   objs, Parse objects
  @param [Object]  collection, Meteor Collection to contain Parse objects
  @return [Object] Meteor collection of Parse objects
###
buildMeteorCollection = (objs, collection) ->
  objCollection = collection or new Meteor.Collection null
  _.each objs, (obj) ->
    objCollection.insert obj.toJSON()
  objCollection

###
  Accepts Parse object and sets ACL giving users in Admin Role read/write access
  @param [Object] obj, Parse object on which to modify ACL
  @return [Promise]
###
setAdminACL = (obj) ->
  acl = if obj.isNew() then new Parse.ACL() else acl = obj.getACL()
  query = new Parse.Query Parse.Role
  query.equalTo 'name', 'admin'
  query.first()
    .then (adminRole) ->
      acl.setPublicReadAccess false
      acl.setPublicWriteAccess false
      acl.setReadAccess adminRole, true
      acl.setWriteAccess adminRole, true
      obj.setACL acl
    .fail (err) ->
      console.log err

###
  Sets ACL giving giving user read access to Parse obj
  @param [Object]   obj, Parse object on which to modify ACL
  @param [Object]   user, Parse User to add to ACL
  @param [Boolean]  access [true], Access rights
###
setUserACL = (obj, user, access=true) ->
  acl = obj.getACL()
  acl.setReadAccess(user, access)
  obj.setACL(acl)

###
  @param [String] Role for which to search
  @return [Promise] Role
###
getRole = (role) ->
  query = new Parse.Query Parse.Role
  query.equalTo 'name', role
  query.first()

###
  @param [String] Type of question
  @return [String] Formated question type string
###
formatQuestionType = (type) ->
  switch type
    when 'number' then 'Number'
    when 'scale' then 'Scale'
    when 'multipleChoice' then 'Multiple Choice'
    when 'checkboxes' then 'Checkbox'
    when 'shortAnswer' then 'Short Answer'
    when 'longAnswer' then 'Long Answer'
    when 'date' then 'Date'
    when 'datetime' then 'DateTime'
    else
      type

module.exports =
  buildMeteorCollection: buildMeteorCollection
  updateSortOrder      : updateSortOrder
  setAdminACL          : setAdminACL
  setUserACL           : setUserACL
  getRole              : getRole
  formatQuestionType   : formatQuestionType
