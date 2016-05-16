Feature: Admin

  @dev
  @admin
  Scenario: Creating a survey
    When I sign in
    And I should see content "Sign Out"
    Then I click "#add-survey"
    And I fill in the add survey form
    And I should see content "Test Survey"
