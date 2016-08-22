Feature: Surveys

  @surveys
  Scenario: Creating a survey
    When I sign in
    Then I click "#add-survey"
    And I fill out the add survey form
    Then I should see content "Test Survey"
