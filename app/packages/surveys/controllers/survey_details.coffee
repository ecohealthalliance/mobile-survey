Template.survey_details.onCreated ->
  @survey = @data.survey
  @surveyDetails = @data.surveyDetails
  @surveyState = @data.surveyState
  @forms = new Meteor.Collection null
  @invitedUsers = new Meteor.Collection null
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
    .then ->
      query = new Parse.Query Parse.User
      query.each (user) ->
        instance.invitedUsers.insert user.toJSON()
    .always ->
      instance.fetched.set true

Template.survey_details.helpers
  survey: ->
    Template.instance().survey

  forms: ->
    Template.instance().forms

  participantCount: ->
    Template.instance().invitedUsers.find().count()

  formCount: ->
    Template.instance().forms.find().count()

  description: ->
    Template.instance().survey.get 'description'

  questionCount: ->
    forms = Template.instance().forms.find()
    questionCount = 0
    forms.forEach (form) ->
      questionCount += form.questions.length
    questionCount
