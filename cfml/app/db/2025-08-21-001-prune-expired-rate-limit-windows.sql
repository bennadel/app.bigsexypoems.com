
INSERT IGNORE INTO
	scheduled_task
SET
	`id` = 'PruneRateLimitWindows',
	`description` = 'I prune expired rate limit windows.',
	`isDailyTask` = FALSE,
	`timeOfDay` = '00:00:00',
	`intervalInMinutes` = 10,
	`state` = JSON_OBJECT(),
	`lastExecutedAt` = '1970-01-01 00:00:00',
	`nextExecutedAt` = '1970-01-01 00:00:00'
;
