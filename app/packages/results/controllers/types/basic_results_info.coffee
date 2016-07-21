Template.basic_results_info.helpers
  particpation: ->
    '30%'
  hasRange: ->
    @type in ['number', 'scale']

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
