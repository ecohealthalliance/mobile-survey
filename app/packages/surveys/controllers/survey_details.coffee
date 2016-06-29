Template.survey_details.onCreated ->
  @survey = @data.survey
  @surveyDetails = @data.surveyDetails
  @surveyState = @data.surveyState
  @forms = new Meteor.Collection null
  @fetched = new ReactiveVar false
  instance = @
  @survey.getForms()
    .then (forms) ->
      if forms.length
        _.each forms, (form) ->
          formProps = form.toJSON()
          form.getTrigger()
            .then (trigger) ->
              formProps.trigger = trigger.attributes
              form.getQuestions()
            .then (questions) ->
              formQuestions = []
              _.each questions, (question) ->
                questionProps = question.toJSON()
                formQuestions.push questionProps
              formProps.questions = formQuestions
              instance.forms.insert formProps
              instance.fetched.set true
      else
        instance.forms = null
        instance.fetched.set true

Template.survey_details.helpers
  survey: ->
    Template.instance().survey
  forms: ->
    Template.instance().forms
