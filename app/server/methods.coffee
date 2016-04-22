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

    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)

    formId = getForms().insert
      name: props.name
      trigger: trigger
      createdBy: @userId
      questions: []
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  editForm: (formId, props) ->
    trigger = null
    if props.trigger
      if props.trigger.type == 'datetime'
        trigger.datetime = new Date(trigger.datetime)
    getForms().update(_id: formId, { $set: props })

  updateForm: (formId, form)->
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    getSurveys().findOne
      _id: id
