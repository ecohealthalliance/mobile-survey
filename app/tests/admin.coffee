clickWhenVisible = (selector)->
  browser.waitForVisible(selector)
  browser.click(selector)

describe 'admin surveys page', ->
  beforeEach ->
    browser.url('http://localhost:3000/admin/surveys')

  it 'can create a survey', ->
    clickWhenVisible('#add-survey')
    browser.waitForExist('.survey-name')
    browser.waitForExist('.survey-title')
    elements = browser.elements('.survey-title')
    assert.equal(elements.value.length, 1)
