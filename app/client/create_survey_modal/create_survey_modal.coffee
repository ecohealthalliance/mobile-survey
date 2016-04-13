Template.create_survey_modal.events
  'submit form': (event, instance) ->
    event.preventDefault()
    form = _.object $(event.target).serializeArray().map(
      ({name, value})-> [name, value]
    )
    Meteor.call 'createSurvey', form, (error, surveyId) ->
      if error
        if _.isObject error.reason
          for key, value of error.reason
            toastr.error('Error: ' + value)
        else
          toastr.error('Unknown Error')
      else
        $(event.target).closest('.modal').modal('hide')
        window.setTimeout(->
          # Wait for modal to hide so the backdrop won't get stuck open.
          toastr.success('Success')
          FlowRouter.go '/admin/surveys/' + surveyId
        , 300)
