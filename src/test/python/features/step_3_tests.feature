Feature: Verion 2 Database

  Scenario: Ensure that the V2_1, V2_2, and V2_3 FlyWay migrations happened correctly
    Given "step_3_flyway_migrate_V2.sh" was run
    Then the "zipster" database schema should be
      |TABLE_NAME           |COLUMN_NAME      |ORDINAL_POSITION|DATA_TYPE|CHARACTER_MAXIMUM_LENGTH|
      |flyway_schema_history|installed_rank   |1               |int      |NULL                    |
      |flyway_schema_history|version          |2               |varchar  |50                      |
      |flyway_schema_history|description      |3               |varchar  |200                     |
      |flyway_schema_history|type             |4               |varchar  |20                      |
      |flyway_schema_history|script           |5               |varchar  |1000                    |
      |flyway_schema_history|checksum         |6               |int      |NULL                    |
      |flyway_schema_history|installed_by     |7               |varchar  |100                     |
      |flyway_schema_history|installed_on     |8               |timestamp|NULL                    |
      |flyway_schema_history|execution_time   |9               |int      |NULL                    |
      |flyway_schema_history|success          |10              |tinyint  |NULL                    |
      |NAME                 |NCONST           |1               |varchar  |31                      |
      |NAME                 |FIRST_NAME       |2               |varchar  |255                     |
      |NAME                 |LAST_NAME        |3               |varchar  |255                     |
      |NAME                 |BIRTH_YEAR       |4               |int      |NULL                    |
      |NAME                 |DEATH_YEAR       |5               |int      |NULL                    |
      |NAME_PROFESSION      |NCONST           |1               |varchar  |31                      |
      |NAME_PROFESSION      |PROFESSION       |2               |varchar  |31                      |
      |NAME_TITLE           |NCONST           |1               |varchar  |31                      |
      |NAME_TITLE           |TCONST           |2               |varchar  |31                      |
      |TITLE                |NCONST           |1               |varchar  |31                      |
      |TITLE                |TITLE_TYPE       |2               |varchar  |31                      |
      |TITLE                |PRIMARY_TITLE    |3               |varchar  |1023                    |
      |TITLE                |ORIGINAL_TITLE   |4               |varchar  |1023                    |
      |TITLE                |IS_ADULT         |5               |tinyint  |NULL                    |
      |TITLE                |START_YEAR       |6               |int      |NULL                    |
      |TITLE                |END_YEAR         |7               |int      |NULL                    |
      |TITLE                |RUNTIME_MINUTES  |8               |int      |NULL                    |
      |TITLE_AKA            |TCONST           |1               |varchar  |31                      |
      |TITLE_AKA            |ORDERING         |2               |int      |NULL                    |
      |TITLE_AKA            |TITLE            |3               |varchar  |1023                    |
      |TITLE_AKA            |REGION           |4               |varchar  |15                      |
      |TITLE_AKA            |LANGUAGE         |5               |varchar  |63                      |
      |TITLE_AKA            |TYPES            |6               |varchar  |63                      |
      |TITLE_AKA            |ATTRIBUTES       |7               |varchar  |63                      |
      |TITLE_AKA            |IS_ORIGINAL_TITLE|8               |tinyint  |NULL                    |
      |TITLE_DIRECTOR       |TCONST           |1               |varchar  |31                      |
      |TITLE_DIRECTOR       |NCONST           |2               |varchar  |31                      |
      |TITLE_EPISODE        |TCONST           |1               |varchar  |31                      |
      |TITLE_EPISODE        |TCONST_PARENT    |2               |varchar  |31                      |
      |TITLE_EPISODE        |SEASON_NUMBER    |3               |int      |NULL                    |
      |TITLE_EPISODE        |EPISODE_NUMBER   |4               |int      |NULL                    |
      |TITLE_GENRE          |NCONST           |1               |varchar  |31                      |
      |TITLE_GENRE          |GENRE            |2               |varchar  |31                      |
      |TITLE_PRINCIPALS     |TCONST           |1               |varchar  |31                      |
      |TITLE_PRINCIPALS     |ORDERING         |2               |int      |NULL                    |
      |TITLE_PRINCIPALS     |NCONST           |3               |varchar  |31                      |
      |TITLE_PRINCIPALS     |CATEGORY         |4               |varchar  |63                      |
      |TITLE_PRINCIPALS     |JOB              |5               |varchar  |255                     |
      |TITLE_PRINCIPALS     |CHARACTER_PLAYED |6               |varchar  |255                     |
      |TITLE_RATING         |TCONST           |1               |varchar  |31                      |
      |TITLE_RATING         |AVERAGE_RATING   |2               |varchar  |15                      |
      |TITLE_RATING         |NUMBER_OF_VOTES  |3               |int      |NULL                    |
      |TITLE_WRITER         |TCONST           |1               |varchar  |31                      |
      |TITLE_WRITER         |NCONST           |2               |varchar  |31                      |
    And the following tables have the following row counts
      |TABLE_NAME      |ROW_COUNT|
      |NAME            |    62350|
      |NAME_PROFESSION |   102914|
      |NAME_TITLE      |   182494|
      |TITLE           |    37359|
      |TITLE_AKA       |    25732|
      |TITLE_DIRECTOR  |    38757|
      |TITLE_EPISODE   |    25413|
      |TITLE_GENRE     |    65920|
      |TITLE_PRINCIPALS|   212556|
      |TITLE_RATING    |     6127|
    And the NAME table has the following sample results
      |NCONST   |FIRST_NAME|LAST_NAME|BIRTH_YEAR|DEATH_YEAR|
      |nm0000007|Humphrey  |Bogart   |1899      |1957      |
      |nm0000859|Lionel    |Barrymore|1878      |1954      |
      |nm0000093|Brad      |Pitt     |1963      |-1        |
      |nm0000678|Kathleen  |Turner   |1954      |-1        |
      |nm0000187|Madonna   |         |1958      |-1        |
      |nm0001145|Divine    |         |1945      |1988      |







