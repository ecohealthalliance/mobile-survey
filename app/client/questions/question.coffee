Template.question.helpers
  questionTemplateName: ->
    data = Template.currentData()
    return "question.#{data.question_type}"
