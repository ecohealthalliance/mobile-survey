Feature: Admin

  @dev
  @admin
  Scenario: Creating a survey
    When I navigate to "/admin/surveys"
    And I click "#add-survey"
    And I fill in the add survey form
    And I should see content "test survey"
