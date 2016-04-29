@Surveys = new Mongo.Collection 'surveys'
@Forms = new Mongo.Collection 'forms'
@Questions = new Mongo.Collection 'questions'

if Meteor.isServer
  Sortable.collections = ['questions', 'forms']
