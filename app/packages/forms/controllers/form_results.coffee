{ formatDate
  formatAnswer }       = require '../imports/format_helpers'
{ formatQuestionType } = require 'meteor/gq:helpers'
fetchForm              = require '../imports/fetch_form'

Template.form_results.onCreated ->
  @selectedFormIdCollection = new Meteor.Collection null
  @selectedFormIds = new ReactiveVar []
  @fetched = new ReactiveVar false
  @queriedFormIds = new Meteor.Collection null
  @lastClickedFormId = new ReactiveVar null
  @forms = new Meteor.Collection null
  @submissions = new Meteor.Collection null
  @questions = new Meteor.Collection null
  @answers = new Meteor.Collection null
  @participants = @data.participants
  @survey = @data.survey

Template.form_results.onRendered ->
  instance = @
  queriedFormIds = instance.queriedFormIds
  fetched = instance.fetched

  # Load all forms initially
  if not @selectedFormIds.get().length and not @lastClickedFormId.get()
    promises = []
    @data.forms.find().forEach (form, i, forms) ->
      promises.push new Promise (resolve) ->
        fetchForm(instance, form.objectId).then ->
          queriedFormIds.insert id: form.objectId
          resolve()

    Promise.all(promises).then ->
      fetched.set true

  @autorun ->
    lastClickedFormId = instance.lastClickedFormId.get()
    _queriedFormIds = _.pluck queriedFormIds.find().fetch(), 'id'

    # Fetch form if not cached
    if not lastClickedFormId in _queriedFormIds
      instance.fetched.set true
      fetchForm instance, lastClickedFormId

    # Add the id of the last clicked form to collection of cached forms
    if lastClickedFormId
      query = id: lastClickedFormId
      instance.queriedFormIds.upsert query, query

    # Update the selectedFormIds
    _selectedFormIds = instance.selectedFormIdCollection.find {}, {fields: {id: 1}}
    instance.selectedFormIds.set _.pluck(_selectedFormIds.fetch(), 'id')

Template.form_results.helpers
  formCollection: ->
    instance = Template.instance()
    forms =
      fetched: instance.fetched
      collection: instance.data.forms
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
    Template.instance().submissions

  fetched: ->
    Template.instance().fetched.get()

  participantIds: ->
    Template.instance().participants.find({}, fields: {objectId: 1}).fetch()

  totalParticipantCount: ->
    Template.instance().participants.find().count()

  csvExport: ->
    instance = Template.instance()
    form = @
    csv = ""
    rows = [ ['email', 'Timestamp'] ]
    hasData = false
    userIds = []
    questionIds = []
    questions = instance.questions
    submissions = instance.submissions

    # Step 1: get the list of Questions for the current form
    questions.find(formId:@objectId)
      .forEach (question, i) ->
        rows[0].push "Question #{i+1}: #{formatQuestionType(question.text)}"
        questionIds.push question.objectId

    # Step 1.5: put the amount of questions into the file name
    form.questionCount = questionIds.length

    # Step 2: retrieve all submissions for the current form
    submissions.find(
      { formId: form.objectId },
      { sort: createdAt: -1 }
    ).forEach (submission) ->
      userIds.push submission.userId.objectId
      hasData = true

    # Step 3: iterate over Participants
    instance.participants.find(objectId: $in: userIds).forEach (user, u) ->
      # Col 1: Username
      result = [ user.username ]
      submissions.find(
        formId: form.objectId
        'userId.objectId': user.objectId
      ).forEach (submission) ->
        # Col 2: Timestamp
        result.push formatDate(submission.createdAt)
        # Cols 3+: Answers
        for questionId in questionIds
          answer = submission.answers[questionId]
          if answer
            type = questions.findOne(objectId:questionId).type
            result.push formatAnswer(answer, type)
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
