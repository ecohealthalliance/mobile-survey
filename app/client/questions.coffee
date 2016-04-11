Template.question.helpers
  questionTemplateName: ->
    data = Template.currentData()
    return "question.#{data.type}"

Template.question_edit.helpers
  questionTemplateName: ->
    data = Template.currentData()
    return "question.#{data.type}.edit"

Template.question_edit.events
  'click .delete': (event, instance) ->
    Questions.remove(instance.data._id)
