{transformObj} = require '../../imports/helpers'

Template.survey_admin_details.onCreated ->
  @survey = @data.survey
  @forms = new Meteor.Collection null
  @fetched = new ReactiveVar false
  instance = @
  @survey.getForms()
    .then (forms) ->
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

Template.survey_admin_details.helpers
  forms: ->
    Template.instance().forms?.find {}, sort: {order: 1}