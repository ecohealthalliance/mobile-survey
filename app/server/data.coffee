Meteor.startup ->
  dummyData =
    [
      {
        question_type: "inputText"
        text: "What is your name?"
        value: "John Doe"
        properties:
          placeholder: "Please Specify Your Full Name"
          maxlength: 20
          required: true
      },
      {
        question_type: "textArea"
        text: "Short bio"
        properties:
          placeholder: "Tell a little about yourself"
          maxlength: 20
      },
      {
        question_type: "inputText"
        text: "How did you find us?"
        properties:
          placeholder: "Web search/newspaper/a friend"
          maxlength: 20
      }
    ]

  unless Questions.findOne()
    question_ids = []

    _.each dummyData, (data, i) ->
      i++
      data.order = i
      question_ids.push Questions.insert(data)

    form_id = Forms.insert
      name: "Test form"
      triggers: []
      questions: question_ids

    Surveys.insert
      title: "Important survey"
      user: null
      created: Date.now()
      forms: [ form_id ]
