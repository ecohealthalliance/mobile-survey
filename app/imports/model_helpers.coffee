###
  Accpets an array of Parse objects and returns a Meteor
  Collection of documents containing the Parse object's
  attributes and id
###
exports.buildMeteorCollection = (objs, collection) ->
  objCollection = collection or new Meteor.Collection null
  _.each objs, (obj) ->
    props = _.extend {}, obj.attributes
    props.parseId = obj.id
    objCollection.insert props
  objCollection
