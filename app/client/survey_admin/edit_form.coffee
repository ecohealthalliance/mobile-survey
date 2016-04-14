Template.edit_form.onCreated ->
  @form = @data.form

Template.edit_form.helpers
  form: ->
    Template.instance().form

Template.edit_form.events
  'submit form': (event, instance)->
    event.preventDefault()
    formObj = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    formObj._id = instance.form._id
    Meteor.call 'updateForm', formObj, (error, formId)->
      if error
        toastr.error('Error')
      else
        FlowRouter.go("""/admin/surveys/#{FlowRouter.getParam('id')}/forms""")
