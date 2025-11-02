
-- I'm setting the default first so that I can stop writing to the column without it
-- throwing an error. Once the code is deployed, I'll drop the column (next statement).
ALTER TABLE
	`poem`
ALTER COLUMN
	`tagID` SET DEFAULT 0
;

-- Move all tags into collections for an easier transition.
INSERT INTO collection
(
	id,
	userID,
	name,
	descriptionMarkdown,
	descriptionHtml,
	createdAt,
	updatedAt
)
SELECT
	id,
	userID,
	name,
	'',
	'',
	createdAt,
	updatedAt
FROM
	tag
;

-- Mirror the tag ID (that we just copied), into the collection ID.
UPDATE
	poem
SET
	collectionID = tagID
;

-- Now we can drop the tag column.
ALTER TABLE
	`poem`
DROP COLUMN
	`tagID`
;
