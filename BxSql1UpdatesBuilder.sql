
SELECT table_name

-- Insert
	, 'INSERT INTO ' || table_name
        || ' (' || string_agg('$' || column_name || '$', ',' ORDER BY ordinal_position) || ')'
	   AS "insert-columns"
    , 'VALUES '
        || ' (' || string_agg('@' || column_name || '@', ',' ORDER BY ordinal_position) || ')'
	   AS "insert-values"

-- Update
    , 'UPDATE ' || table_name
        AS "update-table"
    , 'SET ' || string_agg('$' || column_name || '$=@' || column_name || '@', ',' ORDER BY ordinal_position)
        AS "update-values"

FROM information_schema.columns

WHERE table_name = 'table_name' -- utilizar su imaginación ;-)

GROUP BY table_name 

ORDER BY table_name