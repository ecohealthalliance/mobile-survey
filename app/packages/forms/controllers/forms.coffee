Template.forms.onCreated ->
  @fetched = new ReactiveVar false
  @survey = @data.survey
  instance = @

  @survey.getForms(true).then (forms) ->
    instance.forms = forms
    instance.fetched.set true

Template.forms.helpers
  forms: ->
    Template.instance().forms
