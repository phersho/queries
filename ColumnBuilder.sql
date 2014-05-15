/*
 * Obtiene casi un script de creación de columnas en una tabla.
 */

select 'ALTER TABLE ' || 'order_type' || ' ADD COLUMN ' || column_name
	|| ' ' || upper(data_type) || coalesce(' (' || coalesce(character_maximum_length, numeric_precision, datetime_precision) || ')', '')
	|| (case is_nullable when 'NO' then ' NOT NULL' else '' end)
	|| (case when column_default is not null then ' DEFAULT ' || column_default else '' end)
	|| ';' as script
	--, *

from information_schema.columns

where table_name = 'table' -- utilizar imaginación ;-)
    --and column_name not in ('activated', 'code', 'created', 'created_by', 'deleted', 'description', 'name', 'type', 'updated', 'updated_by')

order by
    column_name,
    ordinal_position
