@Forms = new Mongo.Collection 'forms'
@Questions = new Mongo.Collection 'questions'

if Meteor.isServer
  Sortable.collections = ['questions']

  @Questions.allow
    insert: ->
      true
    remove: ->
      true
    update: ->
      true



Meteor.methods
  addQuestion: (form_id, data) ->
    maxOrder = Questions.findOne({form: form_id}, {sort: order: -1})?.order or 0
    data.order = maxOrder + 1
    data.form = form_id
    Questions.insert data
