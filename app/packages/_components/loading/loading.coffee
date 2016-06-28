Template.loading.onCreated ->
  @classes = @data?.classes or ''
  @inline = @data?.inline

Template.loading.helpers
  classes: ->
    instance = Template.instance()
    if instance.inline
      classes = "#{instance.classes} inline-icon"
    classes
