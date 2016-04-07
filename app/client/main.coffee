@Forms = new Meteor.Collection(null)
@Widgets = new Meteor.Collection(null)


Template.container.helpers
  forms: ->
    Forms.find()


# Meteor.methods
  @addWidget = (form_id, data) ->
    maxOrder = Widgets.findOne({form: form_id}, {sort: order: -1})?.order or 0
    data.order = maxOrder + 1
    data.form = form_id
    Widgets.insert data
