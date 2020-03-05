#!/usr/bin/env bash

figlet -w 200 -f standard "Flyway migrate to V2 (split name)"

figlet -w 160 -f small "Flyway V2_1 (add first and last name)"
mvn -Dflyway.target=2_1 flyway:info flyway:migrate flyway:info

figlet -w 160 -f small "Flyway V2_2 (split primary_name into first and last name)"
mvn -Dflyway.target=2_2 flyway:info flyway:migrate flyway:info

figlet -w 160 -f small "Flyway V2_3 (remove primary_name)"
mvn -Dflyway.target=2_3 flyway:info flyway:migrate flyway:info

cd src/test/python
behave -v features/step_3_tests.feature
cd -