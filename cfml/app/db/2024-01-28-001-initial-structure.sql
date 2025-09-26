
CREATE TABLE `one_time_token` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`slug` varchar(50) NOT NULL,
	`passcode` varchar(255) NOT NULL,
	`value` varchar(255) NOT NULL,
	`expiresAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byExpiration` (`expiresAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(50) NOT NULL,
	`email` varchar(75) NOT NULL,
	`createdAt` datetime NOT NULL,
	`updatedAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `byEmail` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_account` (
	`userID` bigint unsigned NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_session` (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`token` varchar(64) NOT NULL
	`userID` bigint unsigned NOT NULL,
	`isAuthenticated` tinyint unsigned NOT NULL,
	`ipAddress` varchar(45) NOT NULL,
	`createdAt` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `byUser` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_session_presence` (
	`sessionID` bigint unsigned NOT NULL,
	`requestCount` int unsigned NOT NULL,
	`lastRequestAt` datetime NOT NULL,
	PRIMARY KEY (`sessionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_timezone` (
	`userID` bigint unsigned NOT NULL,
	`offsetInMinutes` int NOT NULL,
	PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
