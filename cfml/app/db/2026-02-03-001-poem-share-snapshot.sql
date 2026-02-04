
ALTER TABLE
	`poem_share`
ADD COLUMN
	`isSnapshot` tinyint NOT NULL DEFAULT 0 AFTER `noteHtml`,
ADD COLUMN
	`snapshotName` varchar(255) NOT NULL DEFAULT '' AFTER `isSnapshot`,
ADD COLUMN
	`snapshotContent` varchar(3000) NOT NULL DEFAULT '' AFTER `snapshotName`
;
