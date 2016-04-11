Template.container.onCreated ->
  @subscribe 'form'

Template.container.helpers
  forms: ->
    Forms.find()
