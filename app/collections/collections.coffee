@Surveys = new Mongo.Collection 'surveys'
@Forms = new Mongo.Collection 'forms'
@Questions = new Mongo.Collection 'questions'


Meteor.methods
  addQuestion: (form_id, data) ->
    question_id = Questions.insert data
    if question_id
      form = Forms.findOne(form_id)
      form.questions.push question_id
      Forms.update(form_id, $set: {questions: form.questions})
  removeQuestion: (question_id) ->
    console.log question_id
    Forms.find(questions: question_id).forEach (item) ->
      questions = _.without(item.questions, question_id)
      Forms.update(item._id, $set: questions: questions)
    Questions.remove question_id


if Meteor.isServer
  Sortable.collections = ['questions']

  @Questions.allow
    insert: ->
      true
    remove: ->
      true
    update: ->
      true
