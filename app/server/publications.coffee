Meteor.publish 'surveys', ->
  Surveys.find()

Meteor.publish 'survey', (surveyId) ->
  check(surveyId, String)
  Surveys.find _id: surveyId

Meteor.publish 'form', (formId) ->
  check(formId, String)
  Forms.find _id: formId

Meteor.publish 'surveyForms', (formIds) ->
  check(formIds, [String])
  Forms.find
    _id:
      $in: formIds

Meteor.publish 'questions', (IDs) ->
  check(IDs, [String])
  selector = _.map IDs, (obj) -> { _id: obj }
  if selector.length
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
