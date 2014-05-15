--
-- Tablas que hacen referencia a otra tabla proporcionada por filtro
--

SELECT fk.table_name AS "fk_Table", cu.column_name AS "fk_Column", pk.table_name AS "pk_Table"
    , pt.column_name AS "pk_Column", c.constraint_name AS "Name"

    -- eliminación
    , 'ALTER TABLE "' || fk.table_name || '" DROP CONSTRAINT "' || c.constraint_name || '";' AS "drop-script"

FROM information_schema.referential_constraints c 
INNER JOIN information_schema.table_constraints fk 
	ON c.constraint_name = fk.constraint_name 
INNER JOIN information_schema.table_constraints pk 
	ON c.unique_constraint_name = pk.constraint_name 
INNER JOIN information_schema.key_column_usage cu 
	ON c.constraint_name = cu.constraint_name 
INNER JOIN ( 
	SELECT 
		i1.table_name, i2.column_name 
	FROM information_schema.table_constraints i1 
	INNER JOIN information_schema.key_column_usage i2 
		ON i1.constraint_name = i2.constraint_name 
	WHERE i1.constraint_type ILIKE 'PRIMARY KEY' 
) pt
	ON pt.table_name = pk.table_name 

WHERE pk.table_name ILIKE 'table_name' -- tabla referenciada

ORDER BY 
    fk.table_name, cu.column_name, pk.table_name, pt.column_name
