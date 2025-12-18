
ALTER TABLE
	`user_session`
ADD COLUMN
	`ipCity` varchar(50) NOT NULL DEFAULT '' AFTER `ipAddress`,
ADD COLUMN
	`ipRegion` varchar(50) NOT NULL DEFAULT '' AFTER `ipCity`,
ADD COLUMN
	`ipCountry` varchar(2) NOT NULL DEFAULT '' AFTER `ipRegion`
;

ALTER TABLE
	`user_session`
ALTER COLUMN
	`ipCity` DROP DEFAULT,
ALTER COLUMN
	`ipRegion` DROP DEFAULT,
ALTER COLUMN
	`ipCountry` DROP DEFAULT
;
