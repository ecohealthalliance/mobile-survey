Meteor.methods
  createSurvey: (fields)=>
    # TODO: Validation
    @Surveys.insert(fields)

  getSurvey: (id)=>
    # TODO: Permissions check
    @Surveys.findOne({_id:id})
