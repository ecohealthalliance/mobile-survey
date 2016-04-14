Template.surveys.helpers
  tableSettings: ->
    fields: [
      {
        key: "title"
        label: ""
        fn: (val, obj)->
          new Spacebars.SafeString("""<a href="/admin/surveys/#{obj._id}">#{val}</a>""")
      }
      {
        key: "controls"
        label: ""
        tmpl: Template.survey_item_controls
      }
    ]
    filters: ["tableFilter"]
    noDataTmpl: Template.no_surveys