### Advanced FlyWay Migrations

##### Concept
We need to start treating our databases like code.  

- Keeping databases in code ensures that the process is well defined, automated, and completely transparent.  No more hidden work residing with specialized silos.
- Databases change with the code as part of emerengent design.  We should embrace that rather than deny it.
- Pets vs cattle analogy.  Would you treat your code like a pet and painstakingly patch each byte that changes from release to release hoping that everything still works, or want to be able to build, test, and then deploy it confidently from source using a version controlled repository?
- DevOps culture embraces the team as a whole creating outcomes, rather than exhaustive estimating, managing cross silo dependencies, and tracking work progress in what (by other names) is nothing different than a project plan.

This project demonstrates the use of an open source tool called FlyWay to help us create and migrate databases through their development and growth.  But what this project also demonstrates is that where SQL alone is inadequate to express a mrigration from version N to version N+1, we can use some of the more advanced features of FlyWay (such as a JDBC based migration instead if the usual SQL based migration).

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
```
produces
```console
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
```
produces

```console
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
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 10 source files to /home/howarddeiner/IdeaProjects/advanced-flyway-migrations/target/classes
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:clean (default-cli) @ advanced-flyway-migrations ---
[INFO] Flyway Community Edition 6.2.4 by Redgate
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully cleaned schema `zipster` (execution time 00:00.010s)
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.527 s
[INFO] Finished at: 2020-03-04T12:39:23-05:00
[INFO] Final Memory: 20M/231M
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
[INFO] Successfully validated 5 migrations (execution time 00:00.005s)
[INFO] Creating Schema History table `zipster`.`flyway_schema_history` ...
[INFO] Current version of schema `zipster`: << Empty Schema >>
[INFO] Migrating schema `zipster` to version 1.1 - Create Initial IMDB Schema
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:00.774s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC |                     | Above Target |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.716 s
[INFO] Finished at: 2020-03-04T12:39:25-05:00
[INFO] Final Memory: 11M/227M
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
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC |                     | Pending      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.008s)
[INFO] Current version of schema `zipster`: 1.1
[INFO] Migrating schema `zipster` to version 1.2 - Load Initial IMDB Data
src/main/java/common/data/name.basics.tsv.smaller - 62351 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/name.basics.tsv.smaller - 5% complete - elapsed time = 0:15 - remaining time = 4:43
src/main/java/common/data/name.basics.tsv.smaller - 11% complete - elapsed time = 0:30 - remaining time = 4:00
src/main/java/common/data/name.basics.tsv.smaller - 20% complete - elapsed time = 0:45 - remaining time = 2:58
src/main/java/common/data/name.basics.tsv.smaller - 29% complete - elapsed time = 1:00 - remaining time = 2:22
src/main/java/common/data/name.basics.tsv.smaller - 39% complete - elapsed time = 1:15 - remaining time = 1:53
src/main/java/common/data/name.basics.tsv.smaller - 50% complete - elapsed time = 1:30 - remaining time = 1:29
src/main/java/common/data/name.basics.tsv.smaller - 60% complete - elapsed time = 1:45 - remaining time = 1:07
src/main/java/common/data/name.basics.tsv.smaller - 70% complete - elapsed time = 2:00 - remaining time = 0:50
src/main/java/common/data/name.basics.tsv.smaller - 79% complete - elapsed time = 2:15 - remaining time = 0:34
src/main/java/common/data/name.basics.tsv.smaller - 89% complete - elapsed time = 2:30 - remaining time = 0:18
src/main/java/common/data/name.basics.tsv.smaller - 99% complete - elapsed time = 2:45 - remaining time = 0:00
src/main/java/common/data/name.basics.tsv.smaller - 100% complete - elapsed time = 2:45 - remaining time = 0:00
src/main/java/common/data/title.akas.tsv.smaller - 25733 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.akas.tsv.smaller - 100% complete - elapsed time = 0:13 - remaining time = 0:00
src/main/java/common/data/title.basics.tsv.smaller - 37360 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.basics.tsv.smaller - 30% complete - elapsed time = 0:15 - remaining time = 0:33
src/main/java/common/data/title.basics.tsv.smaller - 64% complete - elapsed time = 0:30 - remaining time = 0:16
src/main/java/common/data/title.basics.tsv.smaller - 95% complete - elapsed time = 0:45 - remaining time = 0:02
src/main/java/common/data/title.basics.tsv.smaller - 100% complete - elapsed time = 0:47 - remaining time = 0:00
src/main/java/common/data/title.crew.tsv.smaller - 37375 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.crew.tsv.smaller - 38% complete - elapsed time = 0:15 - remaining time = 0:24
src/main/java/common/data/title.crew.tsv.smaller - 64% complete - elapsed time = 0:30 - remaining time = 0:16
src/main/java/common/data/title.crew.tsv.smaller - 87% complete - elapsed time = 0:45 - remaining time = 0:06
src/main/java/common/data/title.crew.tsv.smaller - 100% complete - elapsed time = 0:52 - remaining time = 0:00
src/main/java/common/data/title.episode.tsv.smaller - 25414 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.episode.tsv.smaller - 100% complete - elapsed time = 0:11 - remaining time = 0:00
src/main/java/common/data/title.principals.tsv.smaller - 212557 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.principals.tsv.smaller - 15% complete - elapsed time = 0:15 - remaining time = 1:21
src/main/java/common/data/title.principals.tsv.smaller - 27% complete - elapsed time = 0:30 - remaining time = 1:18
src/main/java/common/data/title.principals.tsv.smaller - 42% complete - elapsed time = 0:45 - remaining time = 1:01
src/main/java/common/data/title.principals.tsv.smaller - 58% complete - elapsed time = 1:00 - remaining time = 0:43
src/main/java/common/data/title.principals.tsv.smaller - 73% complete - elapsed time = 1:15 - remaining time = 0:26
src/main/java/common/data/title.principals.tsv.smaller - 90% complete - elapsed time = 1:30 - remaining time = 0:09
src/main/java/common/data/title.principals.tsv.smaller - 100% complete - elapsed time = 1:39 - remaining time = 0:00
src/main/java/common/data/title.ratings.tsv.smaller - 6128 total lines (15 SECOND REPORTING INTERVAL) 
src/main/java/common/data/title.ratings.tsv.smaller - 100% complete - elapsed time = 0:03 - remaining time = 0:00
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 06:33.254s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 1.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Above Target |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 06:34 min
[INFO] Finished at: 2020-03-04T12:46:01-05:00
[INFO] Final Memory: 9M/169M
[INFO] ------------------------------------------------------------------------

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
```
produces

```console
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
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  |                     | Pending      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.009s)
[INFO] Current version of schema `zipster`: 1.2
[INFO] Migrating schema `zipster` to version 2.1 - Add First and Last Name Columns
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:03.235s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.1
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-04 12:46:06 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Above Target |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 4.113 s
[INFO] Finished at: 2020-03-04T12:46:06-05:00
[INFO] Final Memory: 11M/222M
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
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-04 12:46:06 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC |                     | Pending      |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.007s)
[INFO] Current version of schema `zipster`: 2.1
[INFO] Migrating schema `zipster` to version 2.2 - Split Primary Name
splitting PRIMARY_NAME - 62350 total lines (60 SECOND REPORTING INTERVAL) 
splitting PRIMARY_NAME  - 3% complete - elapsed time = 1:00 - remaining time = 25:34
splitting PRIMARY_NAME  - 7% complete - elapsed time = 2:00 - remaining time = 24:32
splitting PRIMARY_NAME  - 11% complete - elapsed time = 3:00 - remaining time = 23:32
splitting PRIMARY_NAME  - 14% complete - elapsed time = 4:00 - remaining time = 22:59
splitting PRIMARY_NAME  - 18% complete - elapsed time = 5:00 - remaining time = 21:59
splitting PRIMARY_NAME  - 22% complete - elapsed time = 6:00 - remaining time = 21:05
splitting PRIMARY_NAME  - 25% complete - elapsed time = 7:00 - remaining time = 20:19
splitting PRIMARY_NAME  - 29% complete - elapsed time = 8:00 - remaining time = 19:24
splitting PRIMARY_NAME  - 32% complete - elapsed time = 9:00 - remaining time = 18:32
splitting PRIMARY_NAME  - 36% complete - elapsed time = 10:00 - remaining time = 17:44
splitting PRIMARY_NAME  - 39% complete - elapsed time = 11:00 - remaining time = 16:50
splitting PRIMARY_NAME  - 42% complete - elapsed time = 12:00 - remaining time = 15:56
splitting PRIMARY_NAME  - 46% complete - elapsed time = 13:00 - remaining time = 15:02
splitting PRIMARY_NAME  - 49% complete - elapsed time = 14:00 - remaining time = 14:09
splitting PRIMARY_NAME  - 52% complete - elapsed time = 15:00 - remaining time = 13:18
splitting PRIMARY_NAME  - 55% complete - elapsed time = 16:00 - remaining time = 12:35
splitting PRIMARY_NAME  - 59% complete - elapsed time = 17:00 - remaining time = 11:41
splitting PRIMARY_NAME  - 62% complete - elapsed time = 18:00 - remaining time = 10:49
splitting PRIMARY_NAME  - 65% complete - elapsed time = 19:00 - remaining time = 9:59
splitting PRIMARY_NAME  - 68% complete - elapsed time = 20:00 - remaining time = 9:10
splitting PRIMARY_NAME  - 71% complete - elapsed time = 21:00 - remaining time = 8:18
splitting PRIMARY_NAME  - 74% complete - elapsed time = 22:00 - remaining time = 7:33
splitting PRIMARY_NAME  - 77% complete - elapsed time = 23:00 - remaining time = 6:42
splitting PRIMARY_NAME  - 80% complete - elapsed time = 24:00 - remaining time = 5:50
splitting PRIMARY_NAME  - 83% complete - elapsed time = 25:00 - remaining time = 5:00
splitting PRIMARY_NAME  - 86% complete - elapsed time = 26:00 - remaining time = 4:00
splitting PRIMARY_NAME  - 89% complete - elapsed time = 27:00 - remaining time = 3:03
splitting PRIMARY_NAME  - 93% complete - elapsed time = 28:00 - remaining time = 2:05
splitting PRIMARY_NAME  - 95% complete - elapsed time = 29:00 - remaining time = 1:12
splitting PRIMARY_NAME  - 98% complete - elapsed time = 30:00 - remaining time = 0:21
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 30:27.465s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.2
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+--------------+
| Category  | Version | Description                     | Type | Installed On        | State        |
+-----------+---------+---------------------------------+------+---------------------+--------------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success      |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success      |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-04 12:46:06 | Success      |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-04 13:16:35 | Success      |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Above Target |
+-----------+---------+---------------------------------+------+---------------------+--------------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 30:28 min
[INFO] Finished at: 2020-03-04T13:16:35-05:00
[INFO] Final Memory: 10M/211M
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
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-04 12:46:06 | Success |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-04 13:16:35 | Success |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  |                     | Pending |
+-----------+---------+---------------------------------+------+---------------------+---------+

[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:migrate (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Successfully validated 5 migrations (execution time 00:00.016s)
[INFO] Current version of schema `zipster`: 2.2
[INFO] Migrating schema `zipster` to version 2.3 - Drop Primary Name Column
[INFO] Successfully applied 1 migration to schema `zipster` (execution time 00:01.760s)
[INFO] 
[INFO] --- flyway-maven-plugin:6.2.4:info (default-cli) @ advanced-flyway-migrations ---
[INFO] Database: jdbc:mysql://localhost:3306/zipster (MySQL 5.7)
[INFO] Schema version: 2.3
[INFO] 
[INFO] +-----------+---------+---------------------------------+------+---------------------+---------+
| Category  | Version | Description                     | Type | Installed On        | State   |
+-----------+---------+---------------------------------+------+---------------------+---------+
| Versioned | 1.1     | Create Initial IMDB Schema      | SQL  | 2020-03-04 12:39:25 | Success |
| Versioned | 1.2     | Load Initial IMDB Data          | JDBC | 2020-03-04 12:46:00 | Success |
| Versioned | 2.1     | Add First and Last Name Columns | SQL  | 2020-03-04 12:46:06 | Success |
| Versioned | 2.2     | Split Primary Name              | JDBC | 2020-03-04 13:16:35 | Success |
| Versioned | 2.3     | Drop Primary Name Column        | SQL  | 2020-03-04 13:16:40 | Success |
+-----------+---------+---------------------------------+------+---------------------+---------+

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.117 s
[INFO] Finished at: 2020-03-04T13:16:40-05:00
[INFO] Final Memory: 11M/223M
[INFO] ------------------------------------------------------------------------

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