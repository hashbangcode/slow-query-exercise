# Slow Query Exercise

An exercise to show how to fix slow MySQL/MariaDB queries.

This includes
- Activating and configuring the slow query log.
- Reading slow query log.
- Creating a database that causes queries to be slow.
- Optimizing the database.

## Activate The Slow Query Log

There are three variables to check for the slow query log.

The first two are:

- `slow_query_log` - A boolean showing if the slow query low is active.
- `slow_query_log_file` - The file to log slow query data to.

```sql
> SHOW GLOBAL VARIABLES LIKE 'slow_query%';
+---------------------+---------------------+
| Variable_name       | Value               |
+---------------------+---------------------+
| slow_query_log      | ON                  |
| slow_query_log_file | /var/log/mysqld.log |
+---------------------+----------------------+
```

There is also `long_query_time`, which is the minimum time (in seconds) before
a query is considered "slow" and is written to the log.

```sql
> SHOW GLOBAL VARIABLES LIKE 'long_query_time';
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| long_query_time | 10.000000 |
+-----------------+-----------+
```

Activate the slow query log using the following commands.

```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysqld-slow.log';
SET GLOBAL long_query_time = 2;
```

You can "trick" the slow query log into activating using the following query.

```sql
SELECT SLEEP(3);
```

This will cause MySQL to sleep and so trigger the slow query log. You should
then see some output in the log at `/var/log/mysqld-slow.log`.

## Read The Slow Query Log

The slow query log can be read simply using `cat /var/log/mysqld-slow.log`, but
you can use the `mysqldumpslow` command to analyse the log for the worst
offenders.

```
mysqldumpslow -t 5 /var/log/mysqld-slow.log
```

This will produce output like this:

```
Reading mysql slow query log from /var/log/mysqld-slow.log
Count: 1  Time=924.57s (924s)  Lock=0.00s (0s)  Rows_sent=60612.0 (60612), Rows_examined=100000.0 (100000), Rows_affected=0.0 (0), root[root]@localhost
  SELECT *
  FROM users AS u
  LEFT JOIN club_members AS cm ON u.id = cm.user_id
  LEFT JOIN clubs AS c ON cm.club_id = c.id
  WHERE cm.user_id IS NULL
```

Once you have identified the slow queries you should use the `EXPLAIN` command
to figure out what is wrong.

## Generate Fake Content

The [Faker](https://fakerphp.github.io/) project is used to generate the fake
data for users and clubs. This is combined into a list of clubs and members.

A simple PHP script is used to generate three CSV files with fake data.

- users.csv - The users.
- clubs.csv - The clubs.
- club_members.csv - The link between users and clubs.

To create the data, do the following:
- Run `composer install` to install the Faker package.
- Run `php faker.php` to generate the data.

This will generate 10,000 user and club records, and half the number of users
as club member records. This is in order to generate users who are not part of
a club.

The queries with 10,000 items of data in a non-optimized setup will take quite
a few seconds, this can be increased to really slow down the example queries.

## Create The Database And Import The Data

Once the csv files have been created the database, tables, and data can be
imported in two ways, using a slow setup and an optimized setup.

### Slow

To install the slow setup.

```
mysql -u root -p < slow_setup.sql
```

The tables in this setup contain no indexes.

### Optimized

To install the optimized setup.

```
mysql -u root -p < optimized_setup.sql
```

This setup adds the required indexes to the tables, but also forces the InnoDB
table manager to be used.

## Queries

Here are some example queries to run.

### Get a list of the users called "Phil"

```sql
SELECT *
FROM users AS u
WHERE forename LIKE 'Phil%';
```

Always less than a second.

### Get a list of all users without a club.

```sql
SELECT *
FROM users AS u
LEFT JOIN club_members AS cm ON u.id = cm.user_id
LEFT JOIN clubs AS c ON cm.club_id = c.id
WHERE cm.user_id IS NULL;
```

On un-optimised tables with 10,000 items of data this query takes around 7
seconds.

After optimizing, the query took 0.1 seconds.

### Get a list of all users in a club

```sql
SELECT *
FROM users AS u
INNER JOIN club_members AS cm ON u.id = cm.user_id
INNER JOIN clubs AS c ON cm.club_id = c.id;
```

On un-optimised tables with 10,000 items of data this query takes around 5
seconds.

After optimizing, the query took 0.1 seconds.

### Get a list of the most popular clubs

```sql
SELECT c.id, c.name, COUNT(cm.club_id)
FROM users AS u
INNER JOIN club_members AS cm ON u.id = cm.user_id
INNER JOIN clubs AS c ON cm.club_id = c.id
GROUP BY (cm.club_id)
HAVING COUNT(cm.club_id) > 1
ORDER BY COUNT(cm.club_id) DESC
LIMIT 10;
```

On un-optimised tables with 10,000 items of data this query takes around 5
seconds.

After optimizing, the query took 0.2 seconds.

If you increase the number of rows from 10,000 to 100,000 then the queries seen
here take over 10 minutes to complete. At this level the slow query log can be
triggered without waiting around for the queries to complete.
