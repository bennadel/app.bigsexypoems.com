
CREATE TABLE `poem_share_viewing` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`poemID` bigint unsigned NOT NULL,
	`shareID` bigint unsigned NOT NULL,
	`ipAddress` varchar(45) NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byPoem` (`poemID`,`shareID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE
	`poem_share`
ADD COLUMN
	`viewingCount` bigint unsigned NOT NULL DEFAULT '0' AFTER `noteHtml`
;
