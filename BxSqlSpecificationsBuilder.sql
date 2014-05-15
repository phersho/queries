SELECT

-- Where
	'[' || column_name || ' :AND ' || column_name  || ' = '
		|| CASE WHEN udt_name IN ('varchar', 'text', 'timestamp', 'date')
			THEN '''@' || column_name || '@'''
			ELSE '@' || column_name || '@' END
		|| ']'
	AS "specification"

/*
-- Update
	, '[' || column_name || ': , ' || column_name  || ' = '
		|| CASE WHEN udt_name IN ('varchar', 'text', 'timestamp', 'date')
			THEN '''@' || column_name || '@'''
			ELSE '@' || column_name || '@' END
		|| ']'
	AS "update"

-- Insert
	, '[' || column_name || ': , ' || column_name
		|| ']'
	AS "insert-columns",
	'[' || column_name || ': , '
		|| CASE WHEN udt_name IN ('varchar', 'text', 'timestamp', 'date')
			THEN '''@' || column_name || '@'''
			ELSE '@' || column_name || '@' END
		||']'
	AS "insert-values"
*/

FROM information_schema.columns

WHERE table_name = 'table_name' -- utilizar su imaginación ;-)

ORDER BY ordinal_position
