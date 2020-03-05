Feature: Start MySQL

  Scenario: Ensure that proper users are in database to allow FlyWay migrations
    Given "step_1_start_mysql.sh" was run
    Then the "User" column in the "mysql.user" table should be
      | User          |
      | FLYWAY        |
      | root          |
      | user          |
      | mysql.session |
      | mysql.sys     |
      | root          |