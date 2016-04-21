Template.edit_questions.onCreated ->
  formId = Template.instance().data.form._id
  @autorun =>
    @subscribe 'questions', Forms.findOne(formId).questions

Template.edit_questions.helpers
  hasQuestions: ->
    Questions.find().count()
  questions: ->
    Questions.find {}, sort: {order: 1}
