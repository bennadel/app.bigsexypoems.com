
CREATE TABLE `tag` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`userID` bigint unsigned NOT NULL,
	`name` varchar(50) NOT NULL,
	`slug` varchar(20) NOT NULL,
	`fillHex` char(6) NOT NULL,
	`textHex` char(6) NOT NULL,
	`createdAt` datetime NOT NULL,
	`updatedAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byUser` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE
	`poem`
ADD COLUMN
	`tagID` bigint unsigned NOT NULL DEFAULT '0' AFTER `userID`
;