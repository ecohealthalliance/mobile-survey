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
    currentFormCount = getSurveys().findOne(surveyId).forms.length
    formId = getForms().insert
      name: props.name
      createdBy: @userId
      questions: []
      order: currentFormCount++
    getSurveys().update({_id: surveyId}, {$addToSet: {forms: formId}})
    formId

  updateForm: (formId, form)->
    getForms().update(_id: formId, { $set: form })

  getSurvey: (id)->
    getSurveys().findOne
      _id: id

  addQuestion: (form_id, data) ->
    question_id = Questions.insert data
    if question_id
      form = Forms.findOne(form_id)
      form.questions.push question_id
      Forms.update(form_id, $set: {questions: form.questions})

  removeQuestion: (question_id) ->
    Forms.find(questions: question_id).forEach (item) ->
      questions = _.without(item.questions, question_id)
      Forms.update(item._id, $set: questions: questions)
    Questions.remove question_id
