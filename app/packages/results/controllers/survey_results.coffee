moment = require 'moment'
floatThead = require 'floatthead'

Template.survey_results.onCreated ->
  @forms = new Meteor.Collection null
  @submissions = new Meteor.Collection null
  @questions = new Meteor.Collection null
  @answers = new Meteor.Collection null
  @users = new Meteor.Collection null
  @fetched = new ReactiveVar false
  @selectedForms = new ReactiveVar []
  @selectedUsers = new ReactiveVar []
  @selectedQuestions = new ReactiveVar []

Template.survey_results.onRendered ->
  instance = @
  @autorun ->
    fetched = instance.fetched.get()
    selectedForms = instance.selectedForms.get()
    Meteor.defer ->
      instance.$('.table').floatThead
        position: 'fixed'

  @survey = @data.survey
  # submissions
  @forms.remove {}
  @submissions.remove {}
  @questions.remove {}
  @answers.remove {}
  @survey.getForms()
    .then (forms) =>
      forms.forEach (form) =>
        _form = form.toJSON()
        # populate the @forms minimongo collection
        form.getTrigger()
          .then (trigger) =>
            _form.trigger = trigger.toJSON()
            delete _form.triggers
            @forms.upsert _form.objectId, _form
        # get results
        query = new Parse.Query('Submission')
        query.equalTo('formId', _form.objectId)
        query.find().then (submissions) =>
          submissions.forEach (submission) =>
            _submission = submission.toJSON()
            @submissions.upsert _submission.objectId, _submission
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
      # users
      @users.remove {}
      query = new Parse.Query Parse.User
      query.find()
        .then (users) =>
          users.forEach (user) =>
            user = user.toJSON()
            userSubmissions = @submissions.find('userId.objectId': user.objectId).fetch()
            user.submittedForms = _.map userSubmissions, (sumbission) ->
              sumbission.formId
            @users.insert user
    .fail (err) ->
      toastr.error err.message
    .always =>
      @fetched.set true

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
      questions.map (question) ->
        question.formId = parentForm.objectId
        question
    else
      false

  _usersFiltered: (question) ->
    users = Template.instance().users
    users = users.find(submittedForms: question.formId).fetch()
    users.map (user) ->
      user.questionId = question.objectId
      user.questionType = question.type
      user

  usersWhoHaveSubmitted: (form) ->
    users = Template.instance().users
    users.find(submittedForms: form.objectId).fetch()

  _answer: (user) ->
    filters = { questionId: user.questionId }
    if user.objectId then filters.userId = user.objectId
    Template.instance().answers.findOne(filters)
  count: (cursor) ->
    cursor?.count() or 0
  submissionsPerForm: (formId) ->
    count = Template.instance().submissions.find(formId: formId).count()
    userCount = Template.instance().users.find().count()
    if userCount
      percentage = count / userCount * 100
      "(#{count}/#{userCount} - #{percentage}%)"
    else
      "(#{count}/#{userCount})"


Template.survey_results.events
  'change #users': (event, instance) ->
    selectedValues = []
    $this = instance.$(event.currentTarget)
    $this.find(':selected').each ->
      if this.value
        selectedValues.push this.value
    instance.selectedUsers.set selectedValues
  'click .form-selector-link': (event, instance) ->
    id = instance.$(event.target).data 'id'
    selectedValues = []
    selectedValues.push id
    instance.selectedForms.set selectedValues

Template.survey_results_question_details.helpers
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
  else if type is 'multipleChoice'
    return group is 'choice'
  else if type is 'checkboxes'
    return group is 'multiple'
  else if type is 'scale'
    return group is 'scale'
  else if type is 'number'
    return group is 'number'
  else if type in ['date', 'datetime']
    return group is 'date'

Template.survey_results_question_details.helpers
  _typeGroup: typeGroup

Template.survey_result.helpers
  _typeGroup: typeGroup

Template.form_info.helpers
  _triggerInfo: (type, properties) ->
    if type is 'datetime'
      time = moment(properties.datetime).format('MMMM Do YYYY \\a\\t h:mm a')
      "#{time}"
  _formatDate: (timestamp) ->
    moment(timestamp).format('MMMM Do YYYY \\a\\t h:mm a')

Template.answer.helpers
  answered: ->
    @answer or not _.isEmpty @answer

  answerType: (type) ->
    type is @type

  _formatDate: (timestamp) ->
    moment(timestamp).format('MMMM Do YYYY, h:mm:ss a')
