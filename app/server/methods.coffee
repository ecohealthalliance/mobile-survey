Meteor.methods
  createSurvey: (fields)=>
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    @Surveys.insert(fields)

  getSurvey: (id)=>
    # TODO: Permissions check
    @Surveys.findOne({_id:id})
