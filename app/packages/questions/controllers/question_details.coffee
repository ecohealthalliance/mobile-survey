Template.question_details.onCreated ->
  instance = @
  @survey = @data.survey
  @question = new ReactiveVar null
  @choices = new Meteor.Collection null
  @submitting = new ReactiveVar false
  @type = new ReactiveVar 'inputText'
  @typeError = new ReactiveVar null
  @data.survey.getForm(@data.formId)
    .then (form) ->
      form.getQuestion(instance.data.questionId)
        .then (question) ->
          instance.question.set question
          instance.type.set question.get 'type'
          if question.get('properties').choices
            question.get('properties').choices.forEach (choice) ->
              instance.choices.insert(name: choice)
        .fail (err) ->
          console.log err
    .fail (err) ->
      console.log err

Template.question_details.helpers
  question: (key) ->
    Template.instance().question.get()
  choices: ->
    Template.instance().choices
  type: ->
    Template.instance().type
