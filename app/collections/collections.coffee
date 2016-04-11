if Meteor.isClient
  @Forms = new Mongo.Collection 'forms'
  @Widgets = new Mongo.Collection 'widgets'

if Meteor.isServer
  @Forms = new Mongo.Collection 'forms'
  @Widgets = new Mongo.Collection 'widgets'

  Sortable.collections = ['widgets']

  @Widgets.allow
    insert: ->
      true
    remove: ->
      true
    update: ->
      true
