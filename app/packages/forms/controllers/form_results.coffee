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
        instance.form = form
        form.getQuestions()
      .then (questions) ->
        _.each questions, (question, i) ->
          question = question.toJSON()
          question.formId = lastClickedFormId
          instance.questions.insert question
          if questions.length == i + 1
            fetched.set true
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

Template.form_results.onRendered ->
  instance = @
  @survey.getForms()
    .then (forms) ->
      forms.forEach (form) ->
        _form = form.toJSON()
        # populate the @forms minimongo collection
        form.getTrigger()
          .then (trigger) ->
            _form.trigger = trigger.toJSON()
            delete _form.triggers
            instance.forms.upsert _form.objectId, _form
        # get forms
        form.getQuestions()
          .then (questions) ->
            _questions = questions.map (item) ->
              item.toJSON().objectId
            instance.forms.update _form.objectId, $set: _questions: _questions
            questions.forEach (question) ->
              _question = question.toJSON()
              _question.questionId = _question.objectId
              # populate the @questions minimongo collection
              instance.questions.upsert _question.objectId, _question
    .fail (err) ->
      console.log err
  # Participants
  formIds = null
  @survey.getForms()
    .then (forms) ->
      formIds = _.map forms, (form) ->
        form.id
      query = new Parse.Query Parse.User
      query.find()
    .then (participants) ->
      _participants = participants
      participants.forEach (participant) ->
        _participant = participant.toJSON()
        instance.participants.insert _participant
    .then ->
      instance.participants.find().forEach (participant) ->
        _participant = new Parse.User()
        _participant.id = participant.objectId
        query = new Parse.Query 'Submission'
        query.containedIn 'formId', formIds
        query.equalTo 'userId', _participant
        query.first()
          .then (submission) ->
            if submission
              instance.participants.update {_id: participant._id}, {$set: {hasSubmitted: true}}
          .fail (err) ->
            console.log err
    .fail (err) ->
      console.log err
  # Submissions (Answers)
  @autorun ->
    instance.submissions.remove {}
    instance.answers.remove {}
    instance.forms.find().forEach (form) ->
      query = new Parse.Query 'Submission'
      query.equalTo('formId', form.objectId)
      query.find()
        .then (submissions) ->
          submissions.forEach (submission) ->
            _submission = submission.toJSON()
            instance.submissions.upsert _submission.objectId, _submission
            for questionId, answer of _submission.answers
              instance.answers.insert
                formId: _submission.formId
                userId: _submission.userId.objectId
                questionId: questionId
                answer: answer
                createdAt: _submission.createdAt
        .fail (err) ->
          console.log err
  # Filter by user - get submissions of user
  @autorun ->
    instance.submissions.remove {}
    instance.answers.remove {}
    instance.forms.find().forEach (form) ->
      query = new Parse.Query 'Submission'
      query.equalTo('formId', form.objectId)
      query.find()
        .then (submissions) ->
          submissions.forEach (submission) ->
            _submission = submission.toJSON()
            instance.submissions.upsert _submission.objectId, _submission
            for questionId, answer of _submission.answers
              instance.answers.insert
                formId: _submission.formId
                userId: _submission.userId.objectId
                questionId: questionId
                answer: answer
                createdAt: _submission.createdAt
        .fail (err) ->
          console.log err

Template.form_results.helpers
  exportButtons: ->
    instance = Template.instance()
    buttons = []
    # Iterate through forms for the current Survey
    instance.forms.find({}, {sort: {order: -1}}).forEach (button) ->
      csv = ""
      rows = [ ['email', 'Timestamp'] ]
      hasData = false
      userIds = []
      questionIds = []
      # Step 1: get the list of Questions for the current form
      filter = { questionId: { $in: button._questions or [] } }
      instance.questions.find(filter).forEach (q, i) ->
        rows[0].push "Question #{i+1}: #{formatQuestionType(q.type)}"
        questionIds.push q.objectId
      # Step 1.5: put the amount of questions into the file name
      button.questionCount = questionIds.length
      # Step 2: retrieve all submissions for the current form
      instance.submissions.find(
        { formId: button.objectId },
        { sort: createdAt: -1 }
      ).forEach (submission) ->
        userIds.push submission.userId.objectId
        hasData = true
      # Step 3: iterate over Participants
      instance.participants.find(objectId: $in: userIds).forEach (user, u) ->
        # Col 1: Username
        result = [ user.username ]
        instance.submissions.find(
          formId: button.objectId
          'userId.objectId': user.objectId
        ).forEach (submission) ->
          # Col 2: Timestamp
          result.push formatDate(submission.createdAt)
          # Cols 3+: Answers
          for a in questionIds
            result.push formatAnswer(
              submission.answers[a],
              instance.questions.findOne(a).type
            )
        rows.push result
      # Final step: Merge rows and columns into a CSV document
      if hasData
        i = 0
        ilen = rows.length
        while i < ilen
          csv += rows[i++].join(',')
          csv += '\n'
        button.data = "data:text/csv;base64,#{btoa csv}"
        buttons.push button
    buttons
  fileName: (formTitle) ->
    formTitle.replace(/\s+/g, '-') + '-results'
formatDate = (dateString) ->
  moment(dateString).format('MM/DD/YYYY hh:mm:ss')
formatQuestionType = (type) ->
  if type is 'number'
    'Number'
  else if type is 'scale'
    'Scale'
  else if type is 'multipleChoice'
    'Multiple Choice'
  else if type is 'checkboxes'
    'Checkbox'
  else if type is 'shortAnswer'
    'Short Answer'
  else if type is 'longAnswer'
    'Long Answer'
  else if type is 'date'
    'Date'
  else if type is 'datetime'
    'DateTime'
  else
    type
formatAnswer = (answer, type) ->
  # console.log type
  if type in [ 'shortAnswer', 'longAnswer' ]
    answer = escapeString(answer)
  else if type is 'date'
    answer = formatDate(answer)
  else if type is 'datetime'
    answer = formatDate(answer.iso)
  else if type in [ 'multipleChoice' ]
    answer = escapeString(answer)
  else if type in [ 'checkboxes' ]
    answer = escapeString(answer.join ',')
  answer
escapeString = (inputString) ->
  inputString = inputString.replace(/\n/g, '\\n')
  inputString = inputString.replace(/"/g, '\\"')
  "\"#{inputString}\""
