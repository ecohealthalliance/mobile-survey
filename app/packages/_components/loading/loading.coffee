Template.loading.onCreated ->
  @classes = @data?.classes
  @inline = @data?.inline

Template.loading.helpers
  classes: ->
    instance = Template.instance()
    classes = instance.classes or ''
    if instance.inline
      "#{classes} inline-icon"
