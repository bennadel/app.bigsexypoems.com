
INSERT INTO `poem_revision`
(
	`poemID`,
	`name`,
	`content`,
	`createdAt`,
	`updatedAt`
)(

	SELECT
		p.`id`,
		p.`name`,
		p.`content`,
		p.`updatedAt`,
		p.`updatedAt`
	FROM
		`poem` p
	WHERE
		NOT EXISTS (

			SELECT
				1
			FROM
				`poem_revision` pr
			WHERE
				pr.`poemID` = p.`id`

		)

);
