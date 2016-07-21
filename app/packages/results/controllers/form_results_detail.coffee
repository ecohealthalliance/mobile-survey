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
    _.each question.answers, (answer) ->
      answers.insert
        content: answer.content
        createdAt: answer.createdAt
        userId: answer.userId

    question: question
    answers: answers

  answers: ->
    Template.instance().data.submissions.find().fetch()

  participation: ->
    usersWithAnswers = _.pluck @answers, 'userId'

    participantCount = usersWithAnswers.length
    totalParticipantCount = Template.instance().data.totalParticipantCount
    percentage =
      (participantCount / totalParticipantCount) * 100

    percentage: Math.round percentage
    count: participantCount
    total: totalParticipantCount
