Template.registerHelper 'fetched', ->
  Template.instance().fetched.get()

Template.registerHelper 'surveyIsActive', ->
  instance = Template.instance()
  survey = instance.survey or instance.data.survey
  survey?.get 'active'

Template.registerHelper 'match', (val, {hash:{regex}})->
  val?.match new RegExp regex

Template.registerHelper 'isEmpty', (val)->
  if val.count
    val.count() == 0
  else
    _.isEmpty val
