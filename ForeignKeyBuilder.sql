
SELECT
	c.table_catalog AS "catalog"
	, c.table_schema AS "schema"
	, c.table_name AS "table"
	, c.column_name AS "column"
	, c.is_nullable AS "nullable"
	, c.is_updatable AS "updatable"

	------------------------------------------------------------------------------------------------
	-- Personalizaciones para crear FKs a Unidades
	, CASE c.is_nullable WHEN 'YES' THEN 'UPDATE "' || c.table_name  || '"'
		|| ' SET "' || c.column_name || '" = NULL WHERE '
		|| '"' || c.column_name || '" NOT IN (SELECT unit_id FROM units);'
		ELSE NULL END AS "UpdateWithNulls"
	, CASE c.is_nullable WHEN 'NO' THEN 'DELETE FROM "' || c.table_name || '" WHERE '
		|| '"' || c.column_name || '" NOT IN (SELECT unit_id FROM units);'
		ELSE NULL END AS "DeleteFromTables"
	, CASE c.is_nullable
		WHEN 'YES' THEN 'UPDATE "' || c.table_name  || '"'
			|| ' SET "' || c.column_name || '" = NULL WHERE '
			|| '"' || c.column_name || '" NOT IN (SELECT unit_id FROM units);'
		WHEN 'NO' THEN 'DELETE FROM "' || c.table_name || '" WHERE '
			|| '"' || c.column_name || '" NOT IN (SELECT unit_id FROM units);'
		ELSE NULL
		END AS "UpdateAndDelete"
	, 'ALTER TABLE "' || c.table_name || '" ADD CONSTRAINT'
		|| ' fk_' || c.table_name || '_units'
		|| ' FOREIGN KEY ("' || c.column_name || '") REFERENCES units (unit_id)'
		|| ' ON UPDATE RESTRICT ON DELETE RESTRICT;'
		AS "FKBuilder"

FROM information_schema.columns c
INNER JOIN information_schema.tables t
	ON c.table_catalog = t.table_catalog
	AND c.table_schema = t.table_schema
	AND c.table_name = t.table_name

WHERE t.table_type NOT IN ('VIEW')
	-- unidades
	--AND t.table_name NOT IN ('units', 'business_units', 'business_units_companies')
	--AND c.column_name NOT IN ('business_unit_id')
	--AND c.column_name ILIKE '%unit_id%'
	AND t.table_name ILIKE '%period%'

ORDER BY c.table_name, c.ordinal_position;
