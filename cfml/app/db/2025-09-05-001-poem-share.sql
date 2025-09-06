
ALTER TABLE
	`poem_share`
ADD COLUMN
	`name` varchar(50) NOT NULL DEFAULT '' AFTER `token`,
ADD COLUMN
	`noteMarkdown` text NOT NULL AFTER `name`,
ADD COLUMN
	`noteHtml` text NOT NULL AFTER `noteMarkdown`,
ADD COLUMN
	`updatedAt` datetime NOT NULL DEFAULT ( `createdAt` ) AFTER `createdAt`
;
