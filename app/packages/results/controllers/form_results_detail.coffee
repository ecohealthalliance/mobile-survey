Template.form_results_detail.helpers
  template: ->
    type = @type
    if type is 'date'
      type = 'datetime'
    else if type in ['longAnswer', 'shortAnswer']
      type = 'text_answer'
    else if type in ['checkboxes', 'multipleChoice']
      type = 'multiple'
    "#{type}_results"

  templateData: ->
    question = @
    questionId = @objectId
    answers = new Meteor.Collection null
    Template.instance().data.submissions.forEach (submission) ->
      answers.insert
        content: submission.answers[questionId]
        createdAt: submission.createdAt

    question: question
    answers: answers

  answers: ->
    Template.instance().data.submissions.fetch()
