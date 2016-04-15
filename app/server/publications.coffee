Meteor.publish 'surveys', ->
  Surveys.find()

Meteor.publish 'survey', (surveyId) ->
  Surveys.find _id: surveyId

Meteor.publish 'forms', ->
  Forms.find()

Meteor.publish 'form', (formId) ->
  Forms.find _id: formId

Meteor.publish 'questions', (IDs) ->
  selector = _.map IDs, (obj) -> { _id: obj }
  Questions.find( $or: selector )

ReactiveTable.publish "administratedSurveys", @Surveys, ->
  if @userId
    {
      createdBy: @userId
    }
  else
    {
      # TODO: Add this line when accounts are added so no results are shown to unauthenticated users.
      # createdBy: "nobody"
    }
