CREATE DATABASE IF NOT EXISTS clubs;

USE clubs;

DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `clubs`;
DROP TABLE IF EXISTS `club_members`;

-- NON-Optimized tables.
CREATE TABLE `users` (
    id INT,
    forename VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL
);

CREATE TABLE `clubs` (
    id INT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE `club_members` (
    user_id INT,
    club_id INT
);

LOAD DATA LOCAL INFILE 'users.csv'
INTO TABLE `users`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE 'clubs.csv'
INTO TABLE `clubs`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE 'club_members.csv'
INTO TABLE `club_members`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';
