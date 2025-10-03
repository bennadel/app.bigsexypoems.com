
ALTER TABLE
	`poem_share_viewing`
ADD COLUMN
	`ipCity` varchar(50) NOT NULL DEFAULT '' AFTER `ipAddress`,
ADD COLUMN
	`ipRegion` varchar(50) NOT NULL DEFAULT '' AFTER `ipCity`,
ADD COLUMN
	`ipCountry` varchar(2) NOT NULL DEFAULT '' AFTER `ipRegion`
;
