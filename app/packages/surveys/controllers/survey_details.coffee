{transformObj} = require 'meteor/gq:helpers'

Template.survey_details.onCreated ->
  @survey = @data.survey
  @forms = new Meteor.Collection null
  @fetched = new ReactiveVar false
  instance = @
  @survey.getForms()
    .then (forms) ->
      if forms.length
        _.each forms, (form) ->
          formProps = transformObj form
          form.getTrigger()
            .then (trigger) ->
              formProps.trigger = trigger.attributes
              form.getQuestions()
            .then (questions) ->
              formQuestions = []
              _.each questions, (question) ->
                questionProps = transformObj question
                formQuestions.push questionProps
              formProps.questions = formQuestions
              instance.forms.insert formProps
              instance.fetched.set true
      else
        instance.forms = null
        instance.fetched.set true

Template.survey_details.helpers
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}
  inactive: ->
    !@survey.attributes.active

  activateButtonText: ->
    if @survey.attributes.active == true then "Deactivate" else "Activate"

  activateButtonClass: ->
    if @survey.attributes.active == true then "mdi-arrow-down-bold-circle-outline" else "mdi-arrow-up-bold-circle-outline"

Template.survey_details.events
  'click .activate': (event, instance)->
    @survey.active = !@survey.active
    props =
      active: @survey.active
    @survey.save(props).then (survey) ->
      state = (if survey.active == true then "activated" else "deactivated")
      toastr.success("You have " + state + " your survey.")
      FlowRouter.go("/admin/surveys/#{instance.survey.id}")
