### Advanced FlyWay Migrations

##### Concept
We need to start treating our databases like code.  

- Keeping databases in code ensures that the process is well defined, automated, and completely transparent.  No more hidden work residing with specialized silos.
- Databases change with the code as part of emerengent design.  We should embrace that rather than deny it.
- Pets vs cattle analogy.  Would you treat your code like a pet and painstakingly patch each byte that changes from release to release hoping that everything still works, or want to be able to build, test, and then deploy it confidently from source using a version controlled repository?
- DevOps culture embraces the team as a whole creating outcomes, rather than exhaustive estimating, managing cross silo dependencies, and tracking work progress in what (by other names) is nothing different than a project plan.

This project demonstrates the use of an open source tool called FlyWay to help us create and migrate databases through their development and growth.  But what this project also demonstrates is that where SQL alone is inadequate to express a mrigration from version N to version N+1, we can use some of the more advanced features of FlyWay (such as a JDBC based migration instead if the usual SQL based migration).  In other words, this project shows how both Schema Migration and Data Migration can work together in a repository based manner with automated testing used to validate all of the actions.

We will start with a database used by IMDB.  We will go through the following migrations:

- V1_1: the initial Schema.  This is a SQL based migration.
- V1_2: the initial static data.  This is a JDBC based migraion, because the data is only made available in TSV (tab seperated values) files.
- V2_1: a migration to add columns FIRST_NAME and LAST_NAME into the NAME table.  This is a SQL based migration.
- V2_2: a migration to split the PRIMARY_NAME column in the NAME table into the FIRST_NAME and LAST_NAME columns.  This is a JDBC based migration, because the steps to split are generally too difficult for SQL expression.
- V2_3: a migration to drop the PRIMARY_NAME column from the NAME table.  This is a SQL based migration.

##### Demo
###### step_1_start_mysql
When run, this script
```bash
#!/usr/bin/env bash

figlet -w 200 -f standard "Start MySQL in docker-composed Environment"

docker-compose -f docker-compose-mysql-and-mysql-data.yml up -d

figlet -w 160 -f small "Wait for MySQL to Start"
while true ; do
  result=$(docker logs mysql 2>&1 | grep -c "Version: '5.7.28'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)")
  if [ $result != 0 ] ; then
    echo "MySQL has started"
    break
  fi
  sleep 5
done

figlet -w 160 -f small "Ready MySQL for FlyWay"
echo "CREATE USER 'FLYWAY' IDENTIFIED BY 'FLWAY';" | mysql -h 127.0.0.1 -P 3306 -u root --password=password  zipster > /dev/null

cd src/test/python
behave -v features/step_1_tests.feature
cd -
```
produces
```console
howarddeiner@ubuntu:~/IdeaProjects/advanced-flyway-migrations$ ./step_1_start_mysql.sh 
 ____  _             _     __  __       ____   ___  _       _             _            _                                                               _ 
/ ___|| |_ __ _ _ __| |_  |  \/  |_   _/ ___| / _ \| |     (_)_ __     __| | ___   ___| | _____ _ __       ___ ___  _ __ ___  _ __   ___  ___  ___  __| |
\___ \| __/ _` | '__| __| | |\/| | | | \___ \| | | | |     | | '_ \   / _` |/ _ \ / __| |/ / _ \ '__|____ / __/ _ \| '_ ` _ \| '_ \ / _ \/ __|/ _ \/ _` |
 ___) | || (_| | |  | |_  | |  | | |_| |___) | |_| | |___  | | | | | | (_| | (_) | (__|   <  __/ | |_____| (_| (_) | | | | | | |_) | (_) \__ \  __/ (_| |
|____/ \__\__,_|_|   \__| |_|  |_|\__, |____/ \__\_\_____| |_|_| |_|  \__,_|\___/ \___|_|\_\___|_|        \___\___/|_| |_| |_| .__/ \___/|___/\___|\__,_|
                                  |___/                                                                                      |_|                         
 _____            _                                      _   
| ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ 
|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __|
| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_ 
|_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|
                                                             
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Creating network "advanced-flyway-migrations_default" with the default driver
Creating mysql ... done
__      __    _ _      __           __  __      ___  ___  _      _         ___ _            _   
\ \    / /_ _(_) |_   / _|___ _ _  |  \/  |_  _/ __|/ _ \| |    | |_ ___  / __| |_ __ _ _ _| |_ 
 \ \/\/ / _` | |  _| |  _/ _ \ '_| | |\/| | || \__ \ (_) | |__  |  _/ _ \ \__ \  _/ _` | '_|  _|
  \_/\_/\__,_|_|\__| |_| \___/_|   |_|  |_|\_, |___/\__\_\____|  \__\___/ |___/\__\__,_|_|  \__|
                                           |__/                                                 
MySQL has started
 ___             _        __  __      ___  ___  _       __           ___ _    __      __         
| _ \___ __ _ __| |_  _  |  \/  |_  _/ __|/ _ \| |     / _|___ _ _  | __| |_  \ \    / /_ _ _  _ 
|   / -_) _` / _` | || | | |\/| | || \__ \ (_) | |__  |  _/ _ \ '_| | _|| | || \ \/\/ / _` | || |
|_|_\___\__,_\__,_|\_, | |_|  |_|\_, |___/\__\_\____| |_| \___/_|   |_| |_|\_, |\_/\_/\__,_|\_, |
                   |__/          |__/                                      |__/             |__/ 
mysql: [Warning] Using a password on the command line interface can be insecure.
Using defaults:
   default_tags 
 stderr_capture True
          junit False
    show_source True
          stage None
        dry_run False
 default_format pretty
   show_timings True
  steps_catalog False
        summary True
 logging_format %(levelname)s:%(name)s:%(message)s
          color True
       userdata {}
   show_skipped True
    log_capture True
  logging_level 20
 stdout_capture True
scenario_outline_annotation_schema {name} -- @{row.id} {examples.name}
  show_snippets True
Supplied path: "features/step_1_tests.feature"
Primary path is to a file so using its directory
Trying base directory: /home/howarddeiner/IdeaProjects/advanced-flyway-migrations/src/test/python/features
Feature: Start MySQL # features/step_1_tests.feature:1

  Scenario: Ensure that proper users are in database to allow FlyWay migrations  # features/step_1_tests.feature:3
    Given "step_1_start_mysql.sh" was run                                        # features/steps/step_1_tests.py:5 0.000s
    Then the "User" column in the "mysql.user" table should be                   # features/steps/step_1_tests.py:9 0.003s
      | User          |
      | FLYWAY        |
      | root          |
      | user          |
      | mysql.session |
      | mysql.sys     |
      | root          |

1 feature passed, 0 failed, 0 skipped
1 scenario passed, 0 failed, 0 skipped
2 steps passed, 0 failed, 0 skipped, 0 undefined
Took 0m0.003s
```
We have merely started up a Docker container with a local MySQL database.

###### step_2_flyway_migrate_V1.sh
When run, this script
```bash
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
```
produces

```console
 _____ _                                       _                 _         _         __     ___    __                   _         _       _ _   _       _ 
|  ___| |_   ___      ____ _ _   _   _ __ ___ (_) __ _ _ __ __ _| |_ ___  | |_ ___   \ \   / / |  / /___ _ __ ___  __ _| |_ ___  (_)_ __ (_) |_(_) __ _| |
| |_  | | | | \ \ /\ / / _` | | | | | '_ ` _ \| |/ _` | '__/ _` | __/ _ \ | __/ _ \   \ \ / /| | | |/ __| '__/ _ \/ _` | __/ _ \ | | '_ \| | __| |/ _` | |
|  _| | | |_| |\ V  V / (_| | |_| | | | | | | | | (_| | | | (_| | ||  __/ | || (_) |   \ V / | | | | (__| | |  __/ (_| | ||  __/ | | | | | | |_| | (_| | |
|_|   |_|\__, | \_/\_/ \__,_|\__, | |_| |_| |_|_|\__, |_|  \__,_|\__\___|  \__\___/     \_/  |_| | |\___|_|  \___|\__,_|\__\___| |_|_| |_|_|\__|_|\__,_|_|
         |___/               |___/               |___/                                            \_\                                                     
     _       _        _                  __  
  __| | __ _| |_ __ _| |__   __ _ ___  __\ \ 
 / _` |/ _` | __/ _` | '_ \ / _` / __|/ _ \ |
| (_| | (_| | || (_| | |_) | (_| \__ \  __/ |
 \__,_|\__,_|\__\__,_|_.__/ \__,_|___/\___| |
                                         /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ advanced-flyway-migrations ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 3 resources
[INFO] 
[INFO] --- maven-compiler-plugin:3.8.1:compile (default-compile) @ advanced-flyway-migrations ---
[INFO] Nothing to compile - all classes are up to date
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:clean (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully cleaned schema `zipster` (execution time 00:00.014s)
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.438 s
[INFO] Finished at: 2020-03-05T10:52:42-05:00
[INFO] Final Memory: 14M/266M
[INFO] ------------------------------------------------------------------------
/home/howarddeiner/IdeaProjects/advanced-flyway-migrations
 ___ _                        __   ___   _    ___      _ _   _      _          _                 __  
| __| |_  ___ __ ____ _ _  _  \ \ / / | / |  / (_)_ _ (_) |_(_)__ _| |  ___ __| |_  ___ _ __  __ \ \ 
| _|| | || \ V  V / _` | || |  \ V /| | | | | || | ' \| |  _| / _` | | (_-</ _| ' \/ -_) '  \/ _` | |
|_| |_|\_, |\_/\_/\__,_|\_, |   \_/ |_|_|_| | ||_|_||_|_|\__|_\__,_|_| /__/\__|_||_\___|_|_|_\__,_| |
       |__/             |__/         |___|   \_\                                                 /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: << Empty Schema >>
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+--------------+--------------+
| Category  | Version | Description                     | Type | Installed On | State        |
+-----------+---------+---------------------------------+------+--------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  |              | Pending      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC |              | Above Target |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |              | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |              | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |              | Above Target |
+-----------+---------+---------------------------------+------+--------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.006s)
[INFO] Creating Schema History table `zipster`.`flyway_schema_history` ...
[INFO] Current version of schema `zipster`: << Empty Schema >>
[INFO] Migrating schema `zipster` to version 1.1 - Create Initial IMDB Schema
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:00.794s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 10:52:44 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC |                     | Above Target |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.810 s
[INFO] Finished at: 2020-03-05T10:52:45-05:00
[INFO] Final Memory: 11M/222M
[INFO] ------------------------------------------------------------------------
 ___ _                        __   ___   ___    ___      _ _   _      _      _        _   _         _      _      __  
| __| |_  ___ __ ____ _ _  _  \ \ / / | |_  )  / (_)_ _ (_) |_(_)__ _| |  __| |_ __ _| |_(_)__   __| |__ _| |_ __ \ \ 
| _|| | || \ V  V / _` | || |  \ V /| |  / /  | || | ' \| |  _| / _` | | (_-<  _/ _` |  _| / _| / _` / _` |  _/ _` | |
|_| |_|\_, |\_/\_/\__,_|\_, |   \_/ |_|_/___| | ||_|_||_|_|\__|_\__,_|_| /__/\__\__,_|\__|_\__| \__,_\__,_|\__\__,_| |
       |__/             |__/         |___|     \_\                                                                /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 10:52:44 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC |                     | Pending      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.014s)
[INFO] Current version of schema `zipster`: 1.1
[INFO] Migrating schema `zipster` to version 1.2 - Load Initial IMDB Data
src/main/java/common/data/name.basics.tsv.smaller - 62351 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/name.basics.tsv.smaller - 6% complete - elapsed time = 0:15 - remaining time = 3:23
src/main/java/common/data/name.basics.tsv.smaller - 15% complete - elapsed time = 0:30 - remaining time = 2:47
src/main/java/common/data/name.basics.tsv.smaller - 24% complete - elapsed time = 0:45 - remaining time = 2:18
src/main/java/common/data/name.basics.tsv.smaller - 34% complete - elapsed time = 1:00 - remaining time = 1:55
src/main/java/common/data/name.basics.tsv.smaller - 43% complete - elapsed time = 1:15 - remaining time = 1:35
src/main/java/common/data/name.basics.tsv.smaller - 53% complete - elapsed time = 1:30 - remaining time = 1:17
src/main/java/common/data/name.basics.tsv.smaller - 63% complete - elapsed time = 1:45 - remaining time = 0:59
src/main/java/common/data/name.basics.tsv.smaller - 75% complete - elapsed time = 2:00 - remaining time = 0:39
src/main/java/common/data/name.basics.tsv.smaller - 85% complete - elapsed time = 2:15 - remaining time = 0:22
src/main/java/common/data/name.basics.tsv.smaller - 95% complete - elapsed time = 2:30 - remaining time = 0:07
src/main/java/common/data/name.basics.tsv.smaller - 100% complete - elapsed time = 2:38 - remaining time = 0:00
src/main/java/common/data/title.akas.tsv.smaller - 25733 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.akas.tsv.smaller - 100% complete - elapsed time = 0:12 - remaining time = 0:00
src/main/java/common/data/title.basics.tsv.smaller - 37360 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.basics.tsv.smaller - 27% complete - elapsed time = 0:15 - remaining time = 0:38
src/main/java/common/data/title.basics.tsv.smaller - 53% complete - elapsed time = 0:30 - remaining time = 0:26
src/main/java/common/data/title.basics.tsv.smaller - 78% complete - elapsed time = 0:45 - remaining time = 0:12
src/main/java/common/data/title.basics.tsv.smaller - 100% complete - elapsed time = 0:58 - remaining time = 0:00
src/main/java/common/data/title.crew.tsv.smaller - 37375 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.crew.tsv.smaller - 35% complete - elapsed time = 0:15 - remaining time = 0:27
src/main/java/common/data/title.crew.tsv.smaller - 60% complete - elapsed time = 0:30 - remaining time = 0:19
src/main/java/common/data/title.crew.tsv.smaller - 81% complete - elapsed time = 0:45 - remaining time = 0:10
src/main/java/common/data/title.crew.tsv.smaller - 100% complete - elapsed time = 0:57 - remaining time = 0:00
src/main/java/common/data/title.episode.tsv.smaller - 25414 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.episode.tsv.smaller - 100% complete - elapsed time = 0:13 - remaining time = 0:00
src/main/java/common/data/title.principals.tsv.smaller - 212557 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.principals.tsv.smaller - 13% complete - elapsed time = 0:15 - remaining time = 1:37
src/main/java/common/data/title.principals.tsv.smaller - 27% complete - elapsed time = 0:30 - remaining time = 1:18
src/main/java/common/data/title.principals.tsv.smaller - 44% complete - elapsed time = 0:45 - remaining time = 0:56
src/main/java/common/data/title.principals.tsv.smaller - 58% complete - elapsed time = 1:00 - remaining time = 0:42
src/main/java/common/data/title.principals.tsv.smaller - 73% complete - elapsed time = 1:15 - remaining time = 0:27
src/main/java/common/data/title.principals.tsv.smaller - 86% complete - elapsed time = 1:30 - remaining time = 0:14
src/main/java/common/data/title.principals.tsv.smaller - 98% complete - elapsed time = 1:45 - remaining time = 0:01
src/main/java/common/data/title.principals.tsv.smaller - 100% complete - elapsed time = 1:47 - remaining time = 0:00
src/main/java/common/data/title.ratings.tsv.smaller - 6128 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.ratings.tsv.smaller - 100% complete - elapsed time = 0:03 - remaining time = 0:00
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 06:49.956s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 10:52:44 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 10:59:36 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 06:50 min
[INFO] Finished at: 2020-03-05T10:59:36-05:00
[INFO] Final Memory: 9M/148M
[INFO] ------------------------------------------------------------------------
Using defaults:
    log_capture True
          stage None
          color True
 stdout_capture True
 default_format pretty
 stderr_capture True
   default_tags 
  show_snippets True
 logging_format %(levelname)s:%(name)s:%(message)s
        dry_run False
   show_timings True
       userdata {}
    show_source True
  steps_catalog False
          junit False
   show_skipped True
scenario_outline_annotation_schema {name} -- @{row.id} {examples.name}
        summary True
  logging_level 20
Supplied path: "features/step_2_tests.feature"
Primary path is to a file so using its directory
Trying base directory: /home/howarddeiner/IdeaProjects/advanced-flyway-migrations/src/test/python/features
Feature: Verion 1 Database # features/step_2_tests.feature:1

  Scenario: Ensure that the V1_1 and V1_2 FlyWay migrations happened correctly  # features/step_2_tests.feature:3
    Given "step_2_flyway_migrate_V1.sh" was run                                 # features/steps/common_step.py:3 0.000s
    Then the "zipster" database schema should be                                # features/steps/step_2_tests.py:5 0.006s
      | TABLE_NAME            | COLUMN_NAME       | ORDINAL_POSITION | DATA_TYPE | CHARACTER_MAXIMUM_LENGTH |
      | flyway_schema_history | installed_rank    | 1                | int       | NULL                     |
      | flyway_schema_history | version           | 2                | varchar   | 50                       |
      | flyway_schema_history | description       | 3                | varchar   | 200                      |
      | flyway_schema_history | type              | 4                | varchar   | 20                       |
      | flyway_schema_history | script            | 5                | varchar   | 1000                     |
      | flyway_schema_history | checksum          | 6                | int       | NULL                     |
      | flyway_schema_history | installed_by      | 7                | varchar   | 100                      |
      | flyway_schema_history | installed_on      | 8                | timestamp | NULL                     |
      | flyway_schema_history | execution_time    | 9                | int       | NULL                     |
      | flyway_schema_history | success           | 10               | tinyint   | NULL                     |
      | NAME                  | NCONST            | 1                | varchar   | 31                       |
      | NAME                  | PRIMARY_NAME      | 2                | varchar   | 255                      |
      | NAME                  | BIRTH_YEAR        | 3                | int       | NULL                     |
      | NAME                  | DEATH_YEAR        | 4                | int       | NULL                     |
      | NAME_PROFESSION       | NCONST            | 1                | varchar   | 31                       |
      | NAME_PROFESSION       | PROFESSION        | 2                | varchar   | 31                       |
      | NAME_TITLE            | NCONST            | 1                | varchar   | 31                       |
      | NAME_TITLE            | TCONST            | 2                | varchar   | 31                       |
      | TITLE                 | NCONST            | 1                | varchar   | 31                       |
      | TITLE                 | TITLE_TYPE        | 2                | varchar   | 31                       |
      | TITLE                 | PRIMARY_TITLE     | 3                | varchar   | 1023                     |
      | TITLE                 | ORIGINAL_TITLE    | 4                | varchar   | 1023                     |
      | TITLE                 | IS_ADULT          | 5                | tinyint   | NULL                     |
      | TITLE                 | START_YEAR        | 6                | int       | NULL                     |
      | TITLE                 | END_YEAR          | 7                | int       | NULL                     |
      | TITLE                 | RUNTIME_MINUTES   | 8                | int       | NULL                     |
      | TITLE_AKA             | TCONST            | 1                | varchar   | 31                       |
      | TITLE_AKA             | ORDERING          | 2                | int       | NULL                     |
      | TITLE_AKA             | TITLE             | 3                | varchar   | 1023                     |
      | TITLE_AKA             | REGION            | 4                | varchar   | 15                       |
      | TITLE_AKA             | LANGUAGE          | 5                | varchar   | 63                       |
      | TITLE_AKA             | TYPES             | 6                | varchar   | 63                       |
      | TITLE_AKA             | ATTRIBUTES        | 7                | varchar   | 63                       |
      | TITLE_AKA             | IS_ORIGINAL_TITLE | 8                | tinyint   | NULL                     |
      | TITLE_DIRECTOR        | TCONST            | 1                | varchar   | 31                       |
      | TITLE_DIRECTOR        | NCONST            | 2                | varchar   | 31                       |
      | TITLE_EPISODE         | TCONST            | 1                | varchar   | 31                       |
      | TITLE_EPISODE         | TCONST_PARENT     | 2                | varchar   | 31                       |
      | TITLE_EPISODE         | SEASON_NUMBER     | 3                | int       | NULL                     |
      | TITLE_EPISODE         | EPISODE_NUMBER    | 4                | int       | NULL                     |
      | TITLE_GENRE           | NCONST            | 1                | varchar   | 31                       |
      | TITLE_GENRE           | GENRE             | 2                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | TCONST            | 1                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | ORDERING          | 2                | int       | NULL                     |
      | TITLE_PRINCIPALS      | NCONST            | 3                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | CATEGORY          | 4                | varchar   | 63                       |
      | TITLE_PRINCIPALS      | JOB               | 5                | varchar   | 255                      |
      | TITLE_PRINCIPALS      | CHARACTER_PLAYED  | 6                | varchar   | 255                      |
      | TITLE_RATING          | TCONST            | 1                | varchar   | 31                       |
      | TITLE_RATING          | AVERAGE_RATING    | 2                | varchar   | 15                       |
      | TITLE_RATING          | NUMBER_OF_VOTES   | 3                | int       | NULL                     |
      | TITLE_WRITER          | TCONST            | 1                | varchar   | 31                       |
      | TITLE_WRITER          | NCONST            | 2                | varchar   | 31                       |
    And the following tables have the following row counts                      # features/steps/step_2_tests.py:33 0.016s
      | TABLE_NAME       | ROW_COUNT |
      | NAME             | 62350     |
      | NAME_PROFESSION  | 102914    |
      | NAME_TITLE       | 182494    |
      | TITLE            | 37359     |
      | TITLE_AKA        | 25732     |
      | TITLE_DIRECTOR   | 38757     |
      | TITLE_EPISODE    | 25413     |
      | TITLE_GENRE      | 65920     |
      | TITLE_PRINCIPALS | 212556    |
      | TITLE_RATING     | 6127      |

1 feature passed, 0 failed, 0 skipped
1 scenario passed, 0 failed, 0 skipped
3 steps passed, 0 failed, 0 skipped, 0 undefined
Took 0m0.022s

```

The script is a little tedious in showing everything going on in deep detail.

Reading along, the script first compiles all of the Java code, invokes a script to get rid of 90% of the data to import (to make the import time more bearable),and then invokes the FlyWay plug-in to clean the schema (which is only necessary if the databaase already has things in it).

It then migrates to version 1_1 and then 1_2 (the first of which would be done ANYWAY, by invoking the second).  It also uses the FlyWay plug-in to show the current migration state, then invokes th migration, then shows the migration state onc again (just to show you that it did sometthing!)

By the end of the script, one can use tools like MySQL Workbench to look around in the database created.  Of course, a nice automated BDD test here would be even better!

###### step_3_flyway_migrate_V2.sh
When run, this script
```bash
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
```
produces

```console
 _____ _                                       _                 _         _         __     ______     __         _ _ _                              __  
|  ___| |_   ___      ____ _ _   _   _ __ ___ (_) __ _ _ __ __ _| |_ ___  | |_ ___   \ \   / /___ \   / /__ _ __ | (_) |_   _ __   __ _ _ __ ___   __\ \ 
| |_  | | | | \ \ /\ / / _` | | | | | '_ ` _ \| |/ _` | '__/ _` | __/ _ \ | __/ _ \   \ \ / /  __) | | / __| '_ \| | | __| | '_ \ / _` | '_ ` _ \ / _ \ |
|  _| | | |_| |\ V  V / (_| | |_| | | | | | | | | (_| | | | (_| | ||  __/ | || (_) |   \ V /  / __/  | \__ \ |_) | | | |_  | | | | (_| | | | | | |  __/ |
|_|   |_|\__, | \_/\_/ \__,_|\__, | |_| |_| |_|_|\__, |_|  \__,_|\__\___|  \__\___/     \_/  |_____| | |___/ .__/|_|_|\__| |_| |_|\__,_|_| |_| |_|\___| |
         |___/               |___/               |___/                                                \_\  |_|                                       /_/ 
 ___ _                        __   _____   _    __       _    _    __ _        _                  _   _         _                       __  
| __| |_  ___ __ ____ _ _  _  \ \ / /_  ) / |  / /_ _ __| |__| |  / _(_)_ _ __| |_   __ _ _ _  __| | | |__ _ __| |_   _ _  __ _ _ __  __\ \ 
| _|| | || \ V  V / _` | || |  \ V / / /  | | | / _` / _` / _` | |  _| | '_(_-<  _| / _` | ' \/ _` | | / _` (_-<  _| | ' \/ _` | '  \/ -_) |
|_| |_|\_, |\_/\_/\__,_|\_, |   \_/ /___|_|_| | \__,_\__,_\__,_| |_| |_|_| /__/\__| \__,_|_||_\__,_| |_\__,_/__/\__| |_||_\__,_|_|_|_\___| |
       |__/             |__/           |___|   \_\                                                                                      /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Pending      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.012s)
[INFO] Current version of schema `zipster`: 1.2
[INFO] Migrating schema `zipster` to version 2.1 - Add First and Last Name Columns
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:02.142s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-05 14:40:54 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.037 s
[INFO] Finished at: 2020-03-05T14:40:54-05:00
[INFO] Final Memory: 11M/220M
[INFO] ------------------------------------------------------------------------
 ___ _                        __   _____   ___    __       _ _ _              _                                             _     _          __ _        _   
| __| |_  ___ __ ____ _ _  _  \ \ / /_  ) |_  )  / /___ __| (_) |_   _ __ _ _(_)_ __  __ _ _ _ _  _   _ _  __ _ _ __  ___  (_)_ _| |_ ___   / _(_)_ _ __| |_ 
| _|| | || \ V  V / _` | || |  \ V / / /   / /  | (_-< '_ \ | |  _| | '_ \ '_| | '  \/ _` | '_| || | | ' \/ _` | '  \/ -_) | | ' \  _/ _ \ |  _| | '_(_-<  _|
|_| |_|\_, |\_/\_/\__,_|\_, |   \_/ /___|_/___| | /__/ .__/_|_|\__| | .__/_| |_|_|_|_\__,_|_|  \_, |_|_||_\__,_|_|_|_\___| |_|_||_\__\___/ |_| |_|_| /__/\__|
       |__/             |__/           |___|     \_\ |_|            |_|                        |__/___|                                                      
              _   _         _                       __  
 __ _ _ _  __| | | |__ _ __| |_   _ _  __ _ _ __  __\ \ 
/ _` | ' \/ _` | | / _` (_-<  _| | ' \/ _` | '  \/ -_) |
\__,_|_||_\__,_| |_\__,_/__/\__| |_||_\__,_|_|_|_\___| |
                                                    /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-05 14:40:54 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Pending      |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.006s)
[INFO] Current version of schema `zipster`: 2.1
[INFO] Migrating schema `zipster` to version 2.2 - Split Primary Name
splitting PRIMARY_NAME - 62350 total lines (60 SECOND REPORTING INTERVAL) 
splitting PRIMARY_NAME  - 3% complete - elapsed time = 1:00 - remaining time = 26:22
splitting PRIMARY_NAME  - 7% complete - elapsed time = 2:00 - remaining time = 25:03
splitting PRIMARY_NAME  - 11% complete - elapsed time = 3:00 - remaining time = 23:35
splitting PRIMARY_NAME  - 15% complete - elapsed time = 4:00 - remaining time = 22:13
splitting PRIMARY_NAME  - 19% complete - elapsed time = 5:00 - remaining time = 21:16
splitting PRIMARY_NAME  - 22% complete - elapsed time = 6:00 - remaining time = 20:12
splitting PRIMARY_NAME  - 26% complete - elapsed time = 7:00 - remaining time = 19:10
splitting PRIMARY_NAME  - 30% complete - elapsed time = 8:00 - remaining time = 18:27
splitting PRIMARY_NAME  - 33% complete - elapsed time = 9:00 - remaining time = 17:35
splitting PRIMARY_NAME  - 37% complete - elapsed time = 10:00 - remaining time = 16:48
splitting PRIMARY_NAME  - 40% complete - elapsed time = 11:00 - remaining time = 15:58
splitting PRIMARY_NAME  - 44% complete - elapsed time = 12:00 - remaining time = 15:07
splitting PRIMARY_NAME  - 47% complete - elapsed time = 13:00 - remaining time = 14:12
splitting PRIMARY_NAME  - 51% complete - elapsed time = 14:00 - remaining time = 13:19
splitting PRIMARY_NAME  - 54% complete - elapsed time = 15:00 - remaining time = 12:27
splitting PRIMARY_NAME  - 58% complete - elapsed time = 16:00 - remaining time = 11:34
splitting PRIMARY_NAME  - 61% complete - elapsed time = 17:00 - remaining time = 10:35
splitting PRIMARY_NAME  - 65% complete - elapsed time = 18:00 - remaining time = 9:37
splitting PRIMARY_NAME  - 68% complete - elapsed time = 19:00 - remaining time = 8:41
splitting PRIMARY_NAME  - 71% complete - elapsed time = 20:00 - remaining time = 7:48
splitting PRIMARY_NAME  - 75% complete - elapsed time = 21:00 - remaining time = 6:56
splitting PRIMARY_NAME  - 78% complete - elapsed time = 22:00 - remaining time = 6:04
splitting PRIMARY_NAME  - 81% complete - elapsed time = 23:00 - remaining time = 5:10
splitting PRIMARY_NAME  - 84% complete - elapsed time = 24:00 - remaining time = 4:19
splitting PRIMARY_NAME  - 88% complete - elapsed time = 25:00 - remaining time = 3:24
splitting PRIMARY_NAME  - 91% complete - elapsed time = 26:00 - remaining time = 2:25
splitting PRIMARY_NAME  - 94% complete - elapsed time = 27:00 - remaining time = 1:29
splitting PRIMARY_NAME  - 98% complete - elapsed time = 28:00 - remaining time = 0:33
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 28:35.732s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-05 14:40:54 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-05 15:09:32 | Success      |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 28:36 min
[INFO] Finished at: 2020-03-05T15:09:32-05:00
[INFO] Final Memory: 11M/225M
[INFO] ------------------------------------------------------------------------
 ___ _                        __   _____   ____   __                                    _                                         __  
| __| |_  ___ __ ____ _ _  _  \ \ / /_  ) |__ /  / / _ ___ _ __  _____ _____   _ __ _ _(_)_ __  __ _ _ _ _  _   _ _  __ _ _ __  __\ \ 
| _|| | || \ V  V / _` | || |  \ V / / /   |_ \ | | '_/ -_) '  \/ _ \ V / -_) | '_ \ '_| | '  \/ _` | '_| || | | ' \/ _` | '  \/ -_) |
|_| |_|\_, |\_/\_/\__,_|\_, |   \_/ /___|_|___/ | |_| \___|_|_|_\___/\_/\___| | .__/_| |_|_|_|_\__,_|_|  \_, |_|_||_\__,_|_|_|_\___| |
       |__/             |__/           |___|     \_\                          |_|                        |__/___|                 /_/ 
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building advanced-flyway-migrations 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+---------+
| Category  | Version | Description                     | Type | Installed On        | State   |
+-----------+---------+---------------------------------+------+---------------------+---------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-05 14:40:54 | Success |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-05 15:09:32 | Success |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Pending |
+-----------+---------+---------------------------------+------+---------------------+---------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.008s)
[INFO] Current version of schema `zipster`: 2.2
[INFO] Migrating schema `zipster` to version 2.3 - Drop Primary Name Column
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:02.808s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.3
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+---------+
| Category  | Version | Description                     | Type | Installed On        | State   |
+-----------+---------+---------------------------------+------+---------------------+---------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-05 14:33:54 | Success |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-05 14:40:37 | Success |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-05 14:40:54 | Success |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-05 15:09:32 | Success |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  | 2020-03-05 15:09:36 | Success |
+-----------+---------+---------------------------------+------+---------------------+---------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.637 s
[INFO] Finished at: 2020-03-05T15:09:37-05:00
[INFO] Final Memory: 11M/223M
[INFO] ------------------------------------------------------------------------
Using defaults:
   default_tags 
scenario_outline_annotation_schema {name} -- @{row.id} {examples.name}
 stderr_capture True
  logging_level 20
  show_snippets True
          junit False
        dry_run False
  steps_catalog False
 logging_format %(levelname)s:%(name)s:%(message)s
       userdata {}
   show_skipped True
    show_source True
          color True
          stage None
    log_capture True
   show_timings True
 stdout_capture True
        summary True
 default_format pretty
Supplied path: "features/step_3_tests.feature"
Primary path is to a file so using its directory
Trying base directory: /home/howarddeiner/IdeaProjects/advanced-flyway-migrations/src/test/python/features
Feature: Verion 2 Database # features/step_3_tests.feature:1

  Scenario: Ensure that the V2_1, V2_2, and V2_3 FlyWay migrations happened correctly  # features/step_3_tests.feature:3
    Given "step_3_flyway_migrate_V2.sh" was run                                        # features/steps/common_steps.py:6 0.000s
    Then the "zipster" database schema should be                                       # features/steps/common_steps.py:10 0.006s
      | TABLE_NAME            | COLUMN_NAME       | ORDINAL_POSITION | DATA_TYPE | CHARACTER_MAXIMUM_LENGTH |
      | flyway_schema_history | installed_rank    | 1                | int       | NULL                     |
      | flyway_schema_history | version           | 2                | varchar   | 50                       |
      | flyway_schema_history | description       | 3                | varchar   | 200                      |
      | flyway_schema_history | type              | 4                | varchar   | 20                       |
      | flyway_schema_history | script            | 5                | varchar   | 1000                     |
      | flyway_schema_history | checksum          | 6                | int       | NULL                     |
      | flyway_schema_history | installed_by      | 7                | varchar   | 100                      |
      | flyway_schema_history | installed_on      | 8                | timestamp | NULL                     |
      | flyway_schema_history | execution_time    | 9                | int       | NULL                     |
      | flyway_schema_history | success           | 10               | tinyint   | NULL                     |
      | NAME                  | NCONST            | 1                | varchar   | 31                       |
      | NAME                  | FIRST_NAME        | 2                | varchar   | 255                      |
      | NAME                  | LAST_NAME         | 3                | varchar   | 255                      |
      | NAME                  | BIRTH_YEAR        | 4                | int       | NULL                     |
      | NAME                  | DEATH_YEAR        | 5                | int       | NULL                     |
      | NAME_PROFESSION       | NCONST            | 1                | varchar   | 31                       |
      | NAME_PROFESSION       | PROFESSION        | 2                | varchar   | 31                       |
      | NAME_TITLE            | NCONST            | 1                | varchar   | 31                       |
      | NAME_TITLE            | TCONST            | 2                | varchar   | 31                       |
      | TITLE                 | NCONST            | 1                | varchar   | 31                       |
      | TITLE                 | TITLE_TYPE        | 2                | varchar   | 31                       |
      | TITLE                 | PRIMARY_TITLE     | 3                | varchar   | 1023                     |
      | TITLE                 | ORIGINAL_TITLE    | 4                | varchar   | 1023                     |
      | TITLE                 | IS_ADULT          | 5                | tinyint   | NULL                     |
      | TITLE                 | START_YEAR        | 6                | int       | NULL                     |
      | TITLE                 | END_YEAR          | 7                | int       | NULL                     |
      | TITLE                 | RUNTIME_MINUTES   | 8                | int       | NULL                     |
      | TITLE_AKA             | TCONST            | 1                | varchar   | 31                       |
      | TITLE_AKA             | ORDERING          | 2                | int       | NULL                     |
      | TITLE_AKA             | TITLE             | 3                | varchar   | 1023                     |
      | TITLE_AKA             | REGION            | 4                | varchar   | 15                       |
      | TITLE_AKA             | LANGUAGE          | 5                | varchar   | 63                       |
      | TITLE_AKA             | TYPES             | 6                | varchar   | 63                       |
      | TITLE_AKA             | ATTRIBUTES        | 7                | varchar   | 63                       |
      | TITLE_AKA             | IS_ORIGINAL_TITLE | 8                | tinyint   | NULL                     |
      | TITLE_DIRECTOR        | TCONST            | 1                | varchar   | 31                       |
      | TITLE_DIRECTOR        | NCONST            | 2                | varchar   | 31                       |
      | TITLE_EPISODE         | TCONST            | 1                | varchar   | 31                       |
      | TITLE_EPISODE         | TCONST_PARENT     | 2                | varchar   | 31                       |
      | TITLE_EPISODE         | SEASON_NUMBER     | 3                | int       | NULL                     |
      | TITLE_EPISODE         | EPISODE_NUMBER    | 4                | int       | NULL                     |
      | TITLE_GENRE           | NCONST            | 1                | varchar   | 31                       |
      | TITLE_GENRE           | GENRE             | 2                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | TCONST            | 1                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | ORDERING          | 2                | int       | NULL                     |
      | TITLE_PRINCIPALS      | NCONST            | 3                | varchar   | 31                       |
      | TITLE_PRINCIPALS      | CATEGORY          | 4                | varchar   | 63                       |
      | TITLE_PRINCIPALS      | JOB               | 5                | varchar   | 255                      |
      | TITLE_PRINCIPALS      | CHARACTER_PLAYED  | 6                | varchar   | 255                      |
      | TITLE_RATING          | TCONST            | 1                | varchar   | 31                       |
      | TITLE_RATING          | AVERAGE_RATING    | 2                | varchar   | 15                       |
      | TITLE_RATING          | NUMBER_OF_VOTES   | 3                | int       | NULL                     |
      | TITLE_WRITER          | TCONST            | 1                | varchar   | 31                       |
      | TITLE_WRITER          | NCONST            | 2                | varchar   | 31                       |
    And the following tables have the following row counts                             # features/steps/common_steps.py:38 0.019s
      | TABLE_NAME       | ROW_COUNT |
      | NAME             | 62350     |
      | NAME_PROFESSION  | 102914    |
      | NAME_TITLE       | 182494    |
      | TITLE            | 37359     |
      | TITLE_AKA        | 25732     |
      | TITLE_DIRECTOR   | 38757     |
      | TITLE_EPISODE    | 25413     |
      | TITLE_GENRE      | 65920     |
      | TITLE_PRINCIPALS | 212556    |
      | TITLE_RATING     | 6127      |
    And the NAME table has the following sample results                                # features/steps/step_3_tests.py:5 0.127s
      | NCONST    | FIRST_NAME | LAST_NAME | BIRTH_YEAR | DEATH_YEAR |
      | nm0000007 | Humphrey   | Bogart    | 1899       | 1957       |
      | nm0000859 | Lionel     | Barrymore | 1878       | 1954       |
      | nm0000093 | Brad       | Pitt      | 1963       | -1         |
      | nm0000678 | Kathleen   | Turner    | 1954       | -1         |
      | nm0000187 | Madonna    |           | 1958       | -1         |
      | nm0001145 | Divine     |           | 1945       | 1988       |

1 feature passed, 0 failed, 0 skipped
1 scenario passed, 0 failed, 0 skipped
4 steps passed, 0 failed, 0 skipped, 0 undefined
Took 0m0.152s

```

The same basic comments about this script being tedious apply from the last script to this one.

It's really quite simple.  We  need three steps to refactor a database that has a VARCHAR column into a database with two VARCHAR columns and preserve design intent.  We can use SQL based migrations to add the two new columns, and remove the superfluous one after a JDBC based migration the understands how to read a string of first and last name from a column and then split it into a first name column and a last name column. 


###### step_4_destroy_mysql.sh
When run, this script
```bash
#!/usr/bin/env bash

figlet -w 200 -f standard "Destroy MySQL docker-composed Environment"

docker-compose -f docker-compose-mysql-and-mysql-data.yml down

sudo -S <<< "password" rm -rf mysql-data
```
produces

```console
|  _ \  ___  ___| |_ _ __ ___  _   _  |  \/  |_   _/ ___| / _ \| |       __| | ___   ___| | _____ _ __       ___ ___  _ __ ___  _ __   ___  ___  ___  __| |
| | | |/ _ \/ __| __| '__/ _ \| | | | | |\/| | | | \___ \| | | | |      / _` |/ _ \ / __| |/ / _ \ '__|____ / __/ _ \| '_ ` _ \| '_ \ / _ \/ __|/ _ \/ _` |
| |_| |  __/\__ \ |_| | | (_) | |_| | | |  | | |_| |___) | |_| | |___  | (_| | (_) | (__|   <  __/ | |_____| (_| (_) | | | | | | |_) | (_) \__ \  __/ (_| |
|____/ \___||___/\__|_|  \___/ \__, | |_|  |_|\__, |____/ \__\_\_____|  \__,_|\___/ \___|_|\_\___|_|        \___\___/|_| |_| |_| .__/ \___/|___/\___|\__,_|
                               |___/          |___/                                                                            |_|                         
 _____            _                                      _   
| ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ 
|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __|
| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_ 
|_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|
                                                             
Stopping mysql ... done
Removing mysql ... done
Removing network advanced-flyway-migrations_default

```

Really not much to say.  We undo step 1, and delete stuff that we created in the process to support the Docker'ized MySQL instance.