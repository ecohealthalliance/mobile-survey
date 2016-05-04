Meteor.publish 'surveys', ->
  unless @userId then return ready()
  Surveys.find()

Meteor.publish 'survey', (surveyId) ->
  unless @userId then return ready()
  Surveys.find _id: surveyId

Meteor.publish 'form', (formId) ->
  unless @userId then return ready()
  Forms.find _id: formId

Meteor.publish 'surveyForms', (formIds) ->
  unless @userId then return ready()
  Forms.find
    _id:
      $in: formIds

Meteor.publish 'questions', (IDs) ->
  unless @userId then return ready()
  selector = _.map IDs, (obj) -> { _id: obj }
  if selector.length
    Questions.find( $or: selector )

ReactiveTable.publish "administratedSurveys", @Surveys, ->
  unless @userId then return ready()
  if @userId
    createdBy: @userId
  else
    # TODO: Add this line when accounts are added so no results are shown to unauthenticated users.
    # createdBy: "nobody"
