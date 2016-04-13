Template.question.helpers
  questionTemplateName: ->
    data = Template.currentData()
    return "question.#{data.question_type}"

# Template.question_edit.helpers
#   questionTemplateName: ->
#     data = Template.currentData()
#     return "question.#{data.type}.edit"

Template.question_edit.events
  'click .delete': (event, instance) ->
    Meteor.call 'removeQuestion', instance.data._id
