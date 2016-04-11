if Meteor.isClient
  @Forms = new Mongo.Collection 'forms'
  @Questions = new Mongo.Collection 'questions'

if Meteor.isServer
  @Forms = new Mongo.Collection 'forms'
  @Questions = new Mongo.Collection 'questions'

  Sortable.collections = ['questions']

  @Questions.allow
    insert: ->
      true
    remove: ->
      true
    update: ->
      true
