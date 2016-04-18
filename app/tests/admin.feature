Feature: Admin

  @dev
  @admin
  Scenario: Deleting a survey
    When I navigate to "/admin/surveys"
    And I should see content "Important survey"
