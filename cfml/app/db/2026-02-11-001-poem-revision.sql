
CREATE TABLE `poem_revision` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`poemID` bigint unsigned NOT NULL,
	`name` varchar(255) NOT NULL,
	`content` varchar(3000) NOT NULL,
	`createdAt` datetime NOT NULL,
	`updatedAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byPoem` (`poemID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
