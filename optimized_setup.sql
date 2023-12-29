CREATE DATABASE IF NOT EXISTS clubs;

USE clubs;

DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `clubs`;
DROP TABLE IF EXISTS `club_members`;

-- NON-Optimized tables.
CREATE TABLE `users` (
    id INT PRIMARY KEY,
    forename VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    FULLTEXT (forename, surname)
) ENGINE=InnoDB;

CREATE TABLE `clubs` (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    FULLTEXT (name)
) ENGINE=InnoDB;

CREATE TABLE `club_members` (
    user_id INT,
    club_id INT,
    INDEX (user_id, club_id)
) ENGINE=InnoDB;

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
