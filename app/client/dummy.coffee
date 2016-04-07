##############
# Dummy data #
##############

Meteor.startup ->
  # Default form
  form_id = Forms.insert(name: "Test form")

  #Meteor.call '
  addWidget form_id,
    type: "inputText"
    label: "Your Name"
    name: "name"
    value: "John Doe"
    required: true
    data:
      placeholder: "Please Specify Your Full Name"
      maxlength: 20
  #Meteor.call '
  addWidget form_id,
    type: "textArea"
    label: "Short bio"
    name: "bio"
    data:
      placeholder: "Tell a little about yourself"
      maxlength: 20
  #Meteor.call '
  addWidget form_id,
    type: "inputText"
    label: "How did you find  us"
    name: "how-did-you"
    data:
      placeholder: "Web search/newspaper/a friend"
      maxlength: 20
