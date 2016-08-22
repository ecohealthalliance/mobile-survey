exports.questions = [
  {
    type: 'multipleChoice'
    text: 'What is your favorite color? (multi)'
    properties: choices: [
      'red'
      'blue'
      'green'
    ]
  }
  {
    type: 'checkboxes'
    text: 'What is your favorite color? (cb)'
    properties: choices: [
      'red'
      'blue'
      'green'
    ]
  }
  {
    type: 'longAnswer'
    text: 'Describe any abnormalities in the location of the drag (long)'
    properties:
      placeholder: 'Long Text...'
      maxlength: 150
  }
  {
    type: 'shortAnswer'
    text: 'Describe any abnormalities in the location of the drag (short)'
    properties:
      placeholder: 'Short Text...'
      maxlength: 20
  }
  {
    type: 'date'
    text: 'When do you plan on doing a follow-up darg? (date)'
    properties: {}
  }
  {
    type: 'datetime'
    text: 'When do you plan on doing a follow-up darg? (datetime)'
    properties: {}
  }
  {
    type: 'number'
    text: 'How many ticks have you found in this sector of the forest?'
    properties:
      min: 0
      max: 999
  }
  {
    type: 'scale'
    text: 'What is the likelyhood hikers in this forest will get bitten by a tick?'
    properties:
      min: 1
      max: 5
      minText: 'None at all.'
      maxText: 'Very likely.'
  }
]
