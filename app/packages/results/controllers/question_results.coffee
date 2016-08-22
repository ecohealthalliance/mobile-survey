moment = require 'moment'

Template.question_results.onCreated ->
  @showIndividualResults = new ReactiveVar false
  @answers = new Meteor.Collection null
  @question = @data.question
  _.each @question.answers, (answer) =>
    @answers.insert
      content: answer.content
      createdAt: answer.createdAt
      userId: answer.userId
      userEmail: answer.userEmail

Template.question_results.helpers
  template: ->
    type = Template.instance().question.type
    if type is 'date'
      type = 'datetime'
    else if type in ['longAnswer', 'shortAnswer']
      type = 'text_answer'
    else if type in ['checkboxes', 'multipleChoice']
      type = 'multiple'
    "#{type}_results"

  templateData: ->
    instance = Template.instance()

    question: instance.question
    answers: instance.answers

  hasSubmissions: ->
    instance = Template.instance()
    questionId = instance.question.objectId
    instance.data.submissions.findOne "answers.#{questionId}": {$exists: true}

  answers: ->
    Template.instance().answers.find()

  participation: ->
    instance = Template.instance()
    usersWithAnswers = _.uniq _.pluck instance.answers.find({}, fields: userId: 1).fetch(), 'userId'

    participantCount = usersWithAnswers.length
    totalParticipantCount = instance.data.totalParticipantCount
    percentage =
      (participantCount / totalParticipantCount) * 100

    percentage: Math.round percentage
    count: participantCount
    total: totalParticipantCount

  showIndividualResults: ->
    Template.instance().showIndividualResults.get()

  resultTemplate: ->
    "#{Template.instance().question.type}-result"

  createdAt: ->
    moment(@createdAt).format 'MM/DD/YYYY hh:mm:ss'

  questionContent: ->
    if Template.instance().question.type in ['datetime', 'date']
      moment(@content).format 'MMMM D, YYYY'
    else
      @content

Template.question_results.events
 'click .show-individual-results': (event, instance) ->
    showResults = instance.showIndividualResults
    showResults.set not showResults.get()
