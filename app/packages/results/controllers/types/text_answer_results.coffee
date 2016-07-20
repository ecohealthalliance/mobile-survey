moment = require 'moment'

Template.text_answer_results.helpers
  recentAnswers: ->
    Template.instance().data.answers.find {},
      sort: createdAt: -1
      limit: 3
  createdAt: ->
    moment(@createdAt).format 'MMMM D, YYYY'
