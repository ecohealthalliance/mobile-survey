###
  Plucks answers out of object (content property)
  @param [Object] answers, answers containing content and createdAt
###
pluckAnswers = (answers) ->
  console.log answers
  _.pluck answers.find().fetch(), 'content'


module.exports =
  pluckAnswers: pluckAnswers
