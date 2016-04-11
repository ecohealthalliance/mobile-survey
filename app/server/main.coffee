Meteor.publish 'questions', ->
  Questions.find()

Meteor.publish 'form', ->
  Forms.find()

Meteor.startup ->
  dummyData =
    [
      {
        type: "inputText"
        label: "Your Name"
        value: "John Doe"
        required: true
        data:
          placeholder: "Please Specify Your Full Name"
          maxlength: 20
      },
      {
        type: "textArea"
        label: "Short bio"
        data:
          placeholder: "Tell a little about yourself"
          maxlength: 20
      },
      {
        type: "inputText"
        label: "How did you find  us"
        data:
          placeholder: "Web search/newspaper/a friend"
          maxlength: 20
      }
    ]
  unless Questions.findOne()
    form_id = Forms.insert(name: "Test form")
    _.each dummyData, (data, i) ->
      i++
      data.form = form_id
      data.order = i
      Questions.insert data
