
CREATE TABLE `poem_revision` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`poemID` bigint unsigned NOT NULL,
	`revisionNumber` int unsigned NOT NULL,
	`content` varchar(3000) NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `byPoemRevision` (`poemID`, `revisionNumber`),
	CONSTRAINT `fk_poem_revision_poem`
		FOREIGN KEY (`poemID`) REFERENCES `poem` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
