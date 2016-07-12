Template.basic_results_info.helpers
  particpation: ->
    '30%'

Template.type_icon.helpers
  icon: ->
    type = Template.instance().data.type
    switch type
      when 'datetime'
        'calendar'
