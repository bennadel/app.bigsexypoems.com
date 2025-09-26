
CREATE TABLE `poem_share` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`poemID` bigint unsigned NOT NULL,
	`token` varchar(32) NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byPoem` (`poemID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
