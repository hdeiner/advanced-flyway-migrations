#!/usr/bin/env bash

figlet -w 200 -f standard "Flyway migrate to V1 (create initial database)"

mvn compile flyway:clean

cd src/main/java/common/data
./runAt10PerCent.sh
cd -

figlet -w 160 -f small "Flyway V1_1 (initial schema)"
mvn -Dflyway.target=1_1 flyway:info flyway:migrate flyway:info

figlet -w 160 -f small "Flyway V1_2 (initial static data)"
mvn -Dflyway.target=1_2 flyway:info flyway:migrate flyway:info

cd src/test/python
behave -v features/step_2_tests.feature
cd -