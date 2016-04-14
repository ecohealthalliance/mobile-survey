Template.survey_admin.onCreated ->
  @subscribe 'survey', @data.id
  @surveyView = new ReactiveVar FlowRouter.current().route.name

Template.survey_admin.helpers
  survey: ->
    Surveys.findOne _id: @id

  surveyView: ->
    Template.instance().surveyView.get()

Template.survey_admin.events
  'click .survey--view-link': (event, instance) ->
    instance.surveyView.set $(event.currentTarget).data 'route'

Template.survey_forms.helpers
  forms: ->
    # forms = Template.instance().surveyRV.get()?.forms
    # if forms
    #   selector = _.map forms, (obj) -> { _id: obj }
    #   Forms.find( $or: selector )
    # else
    #   []
