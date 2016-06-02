{moment} = require 'meteor/momentjs:moment'

Template.survey_results.onCreated ->
  @questions = new Meteor.Collection null
  @answers = new Meteor.Collection null
  @users = new Meteor.Collection null
  @forms = new Meteor.Collection null
  @fetched = new ReactiveVar false
  @selectedForms = new ReactiveVar []
  @selectedUsers = new ReactiveVar []
  @selectedQuestions = new ReactiveVar []
Template.survey_results.onRendered ->
  @survey = @data.survey
  @fetched.set false
  # submissions
  @forms.remove {}
  @questions.remove {}
  @answers.remove {}
  @survey.getForms()
    .then (forms) =>
      forms.forEach (form) =>
        _form = form.toJSON()
        # populate the @forms minimongo collection
        @forms.upsert _form.objectId, _form
        # get results
        query = new Parse.Query('Submission')
        query.equalTo('formId', _form.objectId)
        query.find().then (submissions) =>
          submissions.forEach (submission) =>
            _submission = submission.toJSON()
            for questionId, answer of _submission.answers
              @answers.insert
                formId: _submission.formId
                userId: _submission.userId.objectId
                questionId: questionId
                answer: answer
                # plural: false
                # average:
                createdAt: _submission.createdAt
        # get forms
        form.getQuestions()
          .then (questions) =>
            _questions = questions.map (item) ->
              item.toJSON().objectId
            @forms.update _form.objectId, $set: questions: _questions
            questions.forEach (question) =>
              _question = question.toJSON()
              _question.questionId = _question.objectId
              # populate the @questions minimongo collection
              @questions.upsert _question.objectId, _question
    .fail (err) ->
      toastr.error err.message
    .always =>
      @fetched.set true
  # users
  @users.remove {}
  @survey.relation('invitedUsers').query().find()
    .then (result) =>
      result.forEach (item) =>
        @users.insert item.toJSON()
    .fail (err) ->
      toastr.error err.message

Template.survey_results.helpers
  _forms: ->
    Template.instance().forms.find()
  _questions: ->
    Template.instance().questions.find()
  _users: ->
    Template.instance().users.find()
  _formsFiltered: ->
    selectedForm = Template.instance().selectedForms.get()
    if selectedForm.length
      Template.instance().forms.find({ objectId: $in: selectedForm })
    else
      Template.instance().forms.find()
  _questionsFiltered: (parentForm) ->
    return false unless _.isArray(parentForm.questions)
    selectedQuestions = Template.instance().selectedQuestions.get()
    filters = { questionId: $in: parentForm.questions }
    questions = Template.instance().questions.find(filters)
    if questions.count()
      questions
    else
      false
  _usersFiltered: (question) ->
    selectedUsers = Template.instance().selectedUsers.get()
    filters = {}
    if selectedUsers.length then filters.objectId = { $in: selectedUsers }
    users = Template.instance().users.find(filters)
    users.map (user) ->
      user.questionId = question.objectId
      user.questionType = question.type
      user
  _answer: (user) ->
    filters = { questionId: user.questionId }
    if user.objectId then filters.userId = user.objectId
    Template.instance().answers.findOne(filters)

Template.survey_results.events
  'change #users': (event, instance) ->
    selectedValues = []
    $this = instance.$(event.currentTarget)
    $this.find(':selected').each ->
      if this.value
        selectedValues.push this.value
    instance.selectedUsers.set selectedValues
  'change #forms': (event, instance) ->
    selectedValues = []
    $this = instance.$(event.currentTarget)
    $this.find(':selected').each ->
      if this.value
        selectedValues.push this.value
    instance.selectedForms.set selectedValues

Template.question_details.helpers
  _typeToStr: (type) ->
    switch type
      when 'shortAnswer' then 'Short Answer'
      when 'longAnswer' then 'Long Answer'
      when 'number' then 'Number'
      when 'multipleChoice' then 'One of Many'
      when 'checkboxes' then 'Multiple'
      when 'scale' then 'Scale'
      when 'date' then 'Date'
      when 'datetime' then 'Date/Time'
      else type

typeGroup = (type, group) ->
  if type in ['shortAnswer', 'longAnswer']
    return group is 'simple'
  if type is 'multipleChoice'
    return group is 'choice'
  if type is 'checkboxes'
    return group is 'multiple'
  if type is 'scale'
    return group is 'scale'
  if type is 'number'
    return group is 'number'
  if type in ['date', 'datetime']
    return group is 'date'

Template.question_details.helpers
  _typeGroup: typeGroup

Template.survey_result.helpers
  _typeGroup: typeGroup
  _formatDate: (timestamp) ->
    moment(timestamp).format('MMMM Do YYYY, h:mm:ss a')
