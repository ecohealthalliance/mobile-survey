Feature: Forms
  Background:
    Given there is a survey in the database

  @forms
  Scenario: Adding a form to a survey
    When I sign in
    Then I click ".surveys:first-child"
    Then I click "[data-page=forms]"
    Then I click ".btn-add"
    And I fill out the edit form form
    Then I should see content "Test Form"
