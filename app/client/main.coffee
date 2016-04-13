Template.container.onCreated ->
  @subscribe 'surveys'
  @subscribe 'forms'

Template.container.helpers
  surveys: ->
    Surveys.find()


Template.survey.helpers
  forms: ->
    selector = _.map Template.currentData().forms, (obj) -> { _id: obj }
    Forms.find( $or: selector )
