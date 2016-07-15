Template.basic_results_info.helpers
  particpation: ->
    '30%'
  hasRange: ->
    @type in ['number']

Template.type_icon.helpers
  icon: ->
    switch @type
      when 'datetime'
        'calendar'
      when 'number'
        'hashtag'
