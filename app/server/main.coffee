Meteor.publish 'surveys', ->
  Surveys.find()

Meteor.publish 'forms', ->
  Forms.find()

Meteor.publish 'questions', (IDs) ->
  selector = _.map IDs, (obj) -> { _id: obj }
  Questions.find( $or: selector )
