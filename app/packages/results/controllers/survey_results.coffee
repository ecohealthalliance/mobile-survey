moment = require 'moment'
floatThead = require 'floatthead'

Template.survey_results.onCreated ->
  @forms = new Meteor.Collection null
  @submissions = new Meteor.Collection null
  @questions = new Meteor.Collection null
  @answers = new Meteor.Collection null
  @selectedForms= new Meteor.Collection null
  @selectedQuestions = new ReactiveVar []
  @fetched = new ReactiveVar false
  @participant = @data.participant

Template.survey_results.onRendered ->
  instance = @
  @survey = @data.survey
  @forms.remove {}
  @questions.remove {}

  # Get forms and questions of sruvey
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

  # Filter by user - get submissions of user
  @autorun ->
    instance.submissions.remove {}
    instance.answers.remove {}
    participant = instance.participant.get()
    instance.fetched.set false
    instance.forms?.find().forEach (form) ->
      _participant = new Parse.User()
      _participant.id = participant.objectId
      query = new Parse.Query 'Submission'
      query.equalTo('formId', form.objectId)
      query.equalTo('userId', _participant)
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
        .always ->
          instance.fetched.set true
        .fail (err) ->
          console.log err



Template.survey_results.helpers
  forms: ->
    Template.instance().forms?.find()

  formsFiltered: ->
    selectedFormIds = Template.instance().data.selectedFormIds.find().fetch()
    selectedFormIds = _.map selectedFormIds, (formId) ->
      formId.id
    if selectedFormIds.length
      Template.instance().forms.find({ objectId: $in: selectedFormIds })
    else
      Template.instance().forms.find()

  questions: ->
    return false unless _.isArray @questions
    filters = { questionId: $in: @questions }
    questions = Template.instance().questions.find(filters)
    if questions.count()
      questions.map (question) =>
        question.formId = @objectId
        question
    else
      false

  answer: ->
    instance = Template.instance()
    participant = instance.data.participant.get()
    instance.answers.findOne
      userId: participant.objectId
      questionId: @objectId

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

  allFormsSelected: ->
    not Template.instance().selectedForms.find().count()

  formSelected: ->
    Template.instance().selectedForms.findOne(formId: @objectId)

  participantHasSubmitted: ->
    Template.instance().submissions.findOne formId: @objectId

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
    selectedForms = instance.selectedForms
    query = formId: id
    if id is 'all'
      selectedForms.remove {}
      return
    if selectedForms.findOne(query)
      selectedForms.remove query
    else
      selectedForms.insert query

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

typeGroup = (group) ->
  type = @type
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
  formatDate: ->
    moment(@answer).format('MMMM Do YYYY \\a\\t h:mm a')

Template.answer.helpers
  answered: ->
    @answer or not _.isEmpty @answer

  answerType: (type) ->
    type is @type

  answer: ->
    @answer.answer

  formatDate: ->
    moment(@answer.answer).format('MMMM Do YYYY, h:mm:ss a')
