Template.form_results_detail.helpers
  type: ->
    "#{@type}_results"

  templateData: ->
    questionId = @objectId
    answers = []
    Template.instance().data.submissions.forEach (submission) ->
      answers.push submission.answers[questionId]

    answers: answers
    type: @type

  answers: ->
    Template.instance().data.submissions.fetch()
