Template.loading.onCreated ->
  @classes = @data?.classes
  @inline = @data?.inline

Template.loading.helpers
  classes: ->
    instance = Template.instance()
    classes = instance.data.classes or ''
    if instance.data.inline
      classes = "#{classes} inline-icon"
    classes
