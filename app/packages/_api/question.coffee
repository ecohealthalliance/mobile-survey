{ setAdminACL } = require 'meteor/gq:helpers'

Question = Parse.Object.extend 'Question',
  create: (props, lastQuestionOrder, form) ->
    question = @
    props.order = ++lastQuestionOrder or 1
    props.createdBy = Parse.User.current()
    setAdminACL(question)
      .then ->
        question.save(props)
      .then ->
        question.addToForm(form)
      .then ->
        question

  addToForm: (form) ->
    relation = form.relation 'questions'
    relation.add @
    form.save()
      .then =>
        @

  delete: (deleted = true) ->
    @set 'deleted', deleted
    @save()

  undelete: ->
    @delete(false)

module.exports = Question
