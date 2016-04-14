getSurveys = => @Surveys

Meteor.methods
  createSurvey: (fields)->
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    fields.createdBy = @userId
    getSurveys().insert(fields)

  getSurvey: (id)->
    getSurveys().findOne
      _id: id
