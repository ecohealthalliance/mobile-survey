{ formatQuestionType } = require 'meteor/gq:helpers'

checkNumberLength = (instance, number) ->
  numDigits = number.toString().length
  if numDigits > 4
    instance.longContent.set true

  if numDigits > 8
    number.toExponential 3
  else
    number

Template.basic_results_info.onCreated ->
  @longContent = new ReactiveVar false

Template.basic_results_info.helpers
  hasRange: ->
    @type in ['number', 'scale']

  min: ->
    checkNumberLength Template.instance(), @props.min

  max: ->
    checkNumberLength Template.instance(), @props.max

  longContent: ->
    Template.instance().longContent.get()

Template.type_icon.helpers
  icon: ->
    type = Template.instance().data.type
    switch type
      when 'checkboxes'
        'check-square-o'
      when 'datetime'
        'clock-o'
      when 'date'
        'calendar'
      when 'longAnswer'
        'align-left'
      when 'multipleChoice'
        'list-ul'
      when 'number'
        'hashtag'
      when 'scale'
        'sliders'
      when 'shortAnswer'
        'minus'

  formatQuestionType: -> formatQuestionType(@type)
