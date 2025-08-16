
CREATE TABLE `scheduled_task` (
	`id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
	`description` varchar(50) NOT NULL,
	`isDailyTask` tinyint unsigned NOT NULL,
	`timeOfDay` time NOT NULL,
	`intervalInMinutes` int unsigned NOT NULL,
	`state` json NOT NULL,
	`lastExecutedAt` datetime NOT NULL,
	`nextExecutedAt` datetime NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	KEY `byExecutionDate` (`nextExecutedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO
	scheduled_task
SET
	`id` = 'PruneOneTimeTokens',
	`description` = 'I prune expired one time tokens.',
	`isDailyTask` = FALSE,
	`timeOfDay` = '00:00:00',
	`intervalInMinutes` = 10,
	`state` = JSON_OBJECT(),
	`lastExecutedAt` = '1970-01-01 00:00:00',
	`nextExecutedAt` = '1970-01-01 00:00:00'
;
