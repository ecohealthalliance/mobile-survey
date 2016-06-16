Template.question_details.onCreated ->
  instance = @
  @survey = @data.survey
  @question = new ReactiveVar null
  @submitting = new ReactiveVar false
  @typeError = new ReactiveVar null
  @data.survey.getForm(@data.formId).then (form) ->
    form.getQuestion(instance.data.questionId).then (question) ->
      instance.question.set question
      instance.type.set question.get('type')
      if question.get('properties').choices
        question.get('properties').choices.forEach (choice) ->
          instance.choices.insert(name: choice)
    , (error) ->
      console.error error
  , (error) ->
    console.error error

Template.question_details.helpers
  question: (key) ->
    Template.instance().question.get()?.attributes
