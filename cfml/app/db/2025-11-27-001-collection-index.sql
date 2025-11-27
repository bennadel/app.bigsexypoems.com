
ALTER TABLE
	`poem`
ALTER COLUMN
	`collectionID` DROP DEFAULT,
ADD INDEX
	`byCollection` (`collectionID`)
;
