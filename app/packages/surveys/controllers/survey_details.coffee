{transformObj} = require 'meteor/gq:helpers'

Template.survey_details.onCreated ->
  @survey = @data.survey
  @surveyAttrs = @data.surveyAttrs
  @forms = new Meteor.Collection null
  @fetched = new ReactiveVar false
  @active = new ReactiveVar @survey.get 'active'
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
  survey: ->
    Template.instance().surveyAttrs.get()
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}

  inactive: ->
    not Template.instance().active.get()

  activateButtonText: ->
    if Template.instance().active.get() then "Deactivate" else "Activate"

  activateButtonClass: ->
    if Template.instance().active.get() then "mdi-arrow-down-bold-circle-outline" else "mdi-arrow-up-bold-circle-outline"

Template.survey_details.events
  'click .activate': (event, instance)->
    activeState = instance.active
    activeState.set not activeState.get()
    props =
      active: activeState.get()
    instance.survey.save(props)
      .then (survey) ->
        state = (if activeState.get() then "activated" else "deactivated")
        toastr.success("You have " + state + " your survey.")
        FlowRouter.go("/admin/surveys/#{instance.survey.id}")
