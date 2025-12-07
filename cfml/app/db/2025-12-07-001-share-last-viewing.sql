
ALTER TABLE
	`poem_share`
ADD COLUMN
	`lastViewingAt` datetime DEFAULT NULL AFTER `viewingCount`
;

UPDATE
	`poem_share`
SET
	`lastViewingAt` = (

		SELECT
			MAX( `createdAt` )
		FROM
			`poem_share_viewing`
		WHERE
			`poem_share_viewing`.`shareID` = `poem_share`.`id`

	)
;
