Template.form_results_detail.helpers
  template: ->
    "#{@type}_results"

  templateData: ->
    question = @
    answers = []
    Template.instance().data.submissions.forEach (submission) ->
      answers.push submission.answers[question.objectId]

    question: question
    answers: answers

  answers: ->
    Template.instance().data.submissions.fetch()
