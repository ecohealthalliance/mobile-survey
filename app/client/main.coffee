Template.container.onCreated ->
  @subscribe 'form'

Template.container.helpers
  forms: ->
    Forms.find()


# Meteor.methods
  @addQuestion = (form_id, data) ->
    maxOrder = Questions.findOne({form: form_id}, {sort: order: -1})?.order or 0
    data.order = maxOrder + 1
    data.form = form_id
    Questions.insert data
