CREATE OR REPLACE FUNCTION public.update_fk_deferrable()
  RETURNS CHARACTER VARYING AS
$BODY$
DECLARE
	function_string CHARACTER VARYING;
	stmt RECORD;
BEGIN

CREATE AGGREGATE tmp_array_agg (anyelement)
(
    SFUNC=array_append,
    STYPE=anyarray,
    INITCOND='{}'
);

CREATE TABLE tmp_fk_backup (
    constraint_name TEXT,
    table_name TEXT,
    column_names TEXT,
    references_table TEXT,
    references_names TEXT
);

INSERT INTO tmp_fk_backup
SELECT constraint_name
    , table_name, '(' || array_to_string(tmp_array_agg(column_name), ',') || ')' AS column_names
    , references_table, '(' || array_to_string(tmp_array_agg(references_field), ',') || ')' AS references_names
FROM (
    SELECT tc.constraint_name
        , tc.table_name
        , kcu.column_name::TEXT
        , ccu.table_name AS references_table
        , ccu.column_name::TEXT AS references_field
    FROM information_schema.table_constraints tc
    INNER JOIN information_schema.key_column_usage kcu
        ON tc.constraint_catalog = kcu.constraint_catalog
        AND tc.constraint_schema = kcu.constraint_schema
        AND tc.constraint_name = kcu.constraint_name
    INNER JOIN information_schema.referential_constraints rc
        ON tc.constraint_catalog = rc.constraint_catalog
        AND tc.constraint_schema = rc.constraint_schema
        AND tc.constraint_name = rc.constraint_name
    INNER JOIN information_schema.constraint_column_usage ccu
        ON rc.unique_constraint_catalog = ccu.constraint_catalog
        AND rc.unique_constraint_schema = ccu.constraint_schema
        AND rc.unique_constraint_name = ccu.constraint_name
        AND kcu.column_name = ccu.column_name
    WHERE tc.constraint_type ILIKE 'foreign key'
    GROUP BY tc.constraint_name, tc.table_name, kcu.column_name
        , ccu.table_name, ccu.column_name
) AS fkc -- foreign key constraints
GROUP BY constraint_name, table_name, references_table;

FOR stmt IN
    SELECT 'ALTER TABLE ' || table_name
        || ' DROP CONSTRAINT ' || constraint_name || ';'
        AS drop_fk
    FROM tmp_fk_backup
LOOP
    EXECUTE stmt.drop_fk;
END LOOP;

FOR stmt IN
    SELECT 'ALTER TABLE ' || table_name || ' ADD CONSTRAINT ' || constraint_name 
        || ' FOREIGN KEY ' || column_names || ' REFERENCES ' || references_table || ' ' || references_names
        || ' ON DELETE NO ACTION ON UPDATE CASCADE'
        || ' DEFERRABLE INITIALLY IMMEDIATE;'
        AS create_fk
    FROM tmp_fk_backup
LOOP
    EXECUTE stmt.create_fk;
END LOOP;

DROP AGGREGATE tmp_array_agg(anyelement);
DROP TABLE tmp_fk_backup;

function_string := 'Restricciones actualizadas.';
RETURN function_string;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.update_fk_deferrable()
  OWNER TO postgres;

--select update_fk_deferrable();
