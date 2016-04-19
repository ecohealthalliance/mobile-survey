@Surveys = new Mongo.Collection 'surveys'
@Forms = new Mongo.Collection 'forms'
@Questions = new Mongo.Collection 'questions'


@Surveys.allow
  insert: ->
    true
  remove: ->
    true
  update: ->
    true

@Questions.allow
  insert: ->
    true
  remove: ->
    true
  update: ->
    true

if Meteor.isServer
  Sortable.collections = ['questions', 'forms']
