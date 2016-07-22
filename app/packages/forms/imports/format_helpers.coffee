escapeString = (inputString) ->
  inputString = inputString.replace(/\n/g, '\\n')
  inputString = inputString.replace(/"/g, '\\"')
  "\"#{inputString}\""

formatDate = (dateString) ->
  moment(dateString).format('MM/DD/YYYY hh:mm:ss')

formatAnswer = (answer, type) ->
  switch type
    when 'shortAnswer', 'longAnswer', 'longAnswer'
      escapeString(answer)
    when 'date', 'datetime'
      formatDate(answer)
    when 'multipleChoice' then escapeString(answer)
    when 'checkboxes' then escapeString(answer.join ', ')
    else
      answer

module.exports =
  formatDate: formatDate
  formatAnswer: formatAnswer
