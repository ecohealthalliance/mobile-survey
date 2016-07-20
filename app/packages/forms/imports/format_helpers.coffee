formatDate = (dateString) ->
  moment(dateString).format('MM/DD/YYYY hh:mm:ss')

formatQuestionType = (type) ->
  switch type
    when 'number' then 'Number'
    when 'scale' then 'Scale'
    when 'multipleChoice' then 'Multiple Choice'
    when 'checkboxes' then 'Checkbox'
    when 'shortAnswer' then 'Short Answer'
    when 'longAnswer' then 'Long Answer'
    when 'date' then 'Date'
    when 'datetime' then 'DateTime'
    else
      type

formatAnswer = (answer, type) ->
  switch type
    when 'shortAnswer' then escapeString(answer)
    when 'longAnswer' then escapeString(answer)
    when 'date' then formatDate(answer)
    when 'datetime' then formatDate(answer)
    when 'multipleChoice' then escapeString(answer)
    when 'checkboxes' then escapeString(answer.join ',')
    else
      answer

  if type in [ 'shortAnswer', 'longAnswer' ]
    answer = escapeString(answer)
  else if type is 'date'
    answer = formatDate(answer)
  else if type is 'datetime'
    answer = formatDate(answer.iso)
  else if type is 'multipleChoice'
    answer = escapeString(answer)
  else if type is 'checkboxes'
    answer = escapeString(answer.join ',')
  answer

escapeString = (inputString) ->
  inputString = inputString.replace(/\n/g, '\\n')
  inputString = inputString.replace(/"/g, '\\"')
  "\"#{inputString}\""

module.exports =
  formatDate: formatDate
  formatQuestionType: formatQuestionType
  formatAnswer: formatAnswer
  escapeString: escapeString
