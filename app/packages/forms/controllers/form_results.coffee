{ formatDate
  formatQuestionType
  formatAnswer
  escapeString } = require '../imports/format_helpers'

Template.form_results.onCreated ->
  @selectedFormIdCollection = new Meteor.Collection null
  @selectedFormIds = new ReactiveVar []
  @fetched = new ReactiveVar true
  @queriedFormIds = new Meteor.Collection null
  @lastClickedFormId = new ReactiveVar null
  @forms = new Meteor.Collection null
  @submissions = new Meteor.Collection null
  @questions = new Meteor.Collection null
  @answers = new Meteor.Collection null
  @participants = new Meteor.Collection null
  @survey = @data.survey

Template.form_results.onRendered ->
  instance = @
  @autorun ->
    fetched = instance.fetched
    queriedFormIds = instance.queriedFormIds
    _queriedFormIds = _.pluck queriedFormIds.find().fetch(), 'id'
    lastClickedFormId = instance.lastClickedFormId.get()
    if not lastClickedFormId or lastClickedFormId in _queriedFormIds
      fetched.set true
    else
      fetched.set false
      query = new Parse.Query 'Submission'
      query.equalTo 'formId', lastClickedFormId
      query.each (submission) ->
        instance.submissions.insert submission.toJSON()
      .then ->
        query = new Parse.Query 'Form'
        query.get(lastClickedFormId)
      .then (form) ->
        instance.form = form.toJSON()
        form.getQuestions()
      .then (questions) ->
        _.each questions, (question, i) ->
          question = question.toJSON()
          question.formId = lastClickedFormId
          instance.questions.insert question
        query = new Parse.Query Parse.User
        query.find()
      .then (participants) ->
        participants.forEach (participant) ->
          _participant = participant.toJSON()
          instance.participants.insert _participant

    if lastClickedFormId
      query = id: lastClickedFormId
      queriedFormIds.upsert query, query
    _selectedFormIds = instance.selectedFormIdCollection.find {}, {fields: {id: 1}}
    instance.selectedFormIds.set _.pluck(_selectedFormIds.fetch(), 'id')

Template.form_results.helpers
  formCollection: ->
    forms =
      collection: Template.instance().data.forms
      settings:
        name: 'Forms'
        key: 'title'
        selectable: true
        selectAll: true
    [forms]
  selectedFormIds: ->
    Template.instance().selectedFormIdCollection
  forms: ->
    ids = Template.instance().selectedFormIds.get()
    Template.instance().data.forms.find objectId: {$in: ids}
  questions: ->
    Template.instance().questions.find formId: @objectId
  lastClickedFormId: ->
    Template.instance().lastClickedFormId
  submissions: ->
    Template.instance().submissions.find formId: @objectId

  csvExport: ->
    instance = Template.instance()
    form = @
    csv = ""
    rows = [ ['email', 'Timestamp'] ]
    hasData = false
    userIds = []
    questionIds = []

    # Step 1: get the list of Questions for the current form
    instance.questions.find(formId:@objectId)
      .forEach (question, i) ->
        rows[0].push "Question #{i+1}: #{formatQuestionType(question.text)}"
        questionIds.push question.objectId

    # Step 1.5: put the amount of questions into the file name
    form.questionCount = questionIds.length

    # Step 2: retrieve all submissions for the current form
    instance.submissions.find(
      { formId: form.objectId },
      { sort: createdAt: -1 }
    ).forEach (submission) ->
      userIds.push submission.userId.objectId
      hasData = true

    # Step 3: iterate over Participants
    instance.participants.find(objectId: $in: userIds).forEach (user, u) ->
      # Col 1: Username
      result = [ user.username ]
      instance.submissions.find(
        formId: form.objectId
        'userId.objectId': user.objectId
      ).forEach (submission) ->
        # Col 2: Timestamp
        result.push formatDate(submission.createdAt)
        # Cols 3+: Answers
        for questionId in questionIds
          result.push formatAnswer(
            submission.answers[questionId],
            instance.questions.findOne(objectId:questionId).type
          )
      rows.push result

    # Final step: Merge rows and columns into a CSV document
    if hasData
      i = 0
      ilen = rows.length
      while i < ilen
        csv += rows[i++].join(',')
        csv += '\n'

    "data:text/csv;base64,#{btoa csv}"

  fileName: (formTitle) ->
    formTitle.replace(/\s+/g, '-') + '-results'
