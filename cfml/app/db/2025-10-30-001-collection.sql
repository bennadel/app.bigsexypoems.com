
CREATE TABLE `collection` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`userID` bigint unsigned NOT NULL,
	`name` varchar(50) NOT NULL,
	`descriptionMarkdown` text NOT NULL,
	`descriptionHtml` text NOT NULL,
	`createdAt` datetime NOT NULL,
	`updatedAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byUser` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE
	`poem`
ADD COLUMN
	`collectionID` bigint unsigned NOT NULL DEFAULT '0' AFTER `userID`
;
