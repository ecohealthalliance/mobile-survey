getSurveys = => @Surveys
getForms = => @Forms

Meteor.methods
  createSurvey: (fields)->
    if not fields?.title or fields.title.length == 0
      throw new Meteor.Error("The title field cannot be empty")
    fields.createdBy = @userId
    getSurveys().insert(fields)

  createForm: (surveyId, props)->
    #TODO Authenticate
    #TODO Validate
    formId = getForms().insert
      name: props.name
      trigger: props.trigger
      createdBy: @userId
      questions: []
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  updateForm: (formId, form)->
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    getSurveys().findOne
      _id: id
