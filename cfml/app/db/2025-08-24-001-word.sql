
CREATE TABLE `word` (
	`token` varchar(20) NOT NULL,
	`syllableCount` tinyint unsigned NOT NULL,
	`partsPerMillion` decimal(12,6) unsigned NOT NULL,
	`isAdjective` tinyint unsigned NOT NULL,
	`isAdverb` tinyint unsigned NOT NULL,
	`isNoun` tinyint unsigned NOT NULL,
	`isVerb` tinyint unsigned NOT NULL,
	PRIMARY KEY (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
