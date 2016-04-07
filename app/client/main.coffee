@Forms = new Meteor.Collection(null)


Forms.attachSchema new SimpleSchema(
  fields:
    type: [ Object ]
  'fields.$.name':
    type: String
  'fields.$.label':
    type: String
  'fields.$.type':
    type: String
    allowedValues: [
      'Boolean'
      'String'
      'Date'
      'Number'
    ])


TypeSchemas =
  Boolean:
    type: Boolean
  String:
    type: String
  Date:
    type: Date
  Number:
    type: Number


Template.forms.onCreated ->
  Forms.insert(fields: [
    {
      label: 'Name',
      name: 'name',
      type: 'String'
    },
    {
      label: 'DoB',
      name: 'dob',
      type: 'Date'
    }
  ])


Template.forms.helpers
  forms: ->
    Forms.find()

Template.form.helpers
  updateFormId: ->
    'update_' + @_id
  schema: ->
    schema = {}
    len = @fields.length
    i = 0
    while i < len
      field = @fields[i]
      schema[field.name] =
        type: field.type
        label: field.label
      i++
    new SimpleSchema(schema)



Template.container.helpers
  hasForms: ->
    Forms.find().count()
