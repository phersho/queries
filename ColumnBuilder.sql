/*
 * Gets script for add columns.
 */

select format('%s.%s.%s', table_schema, table_name, column_name) as "Column"
    , format('ALTER TABLE %s.%s ADD COLUMN %s %s', table_schema, table_name, column_name, upper(data_type))
    || coalesce(' (' || coalesce(character_maximum_length, numeric_precision, datetime_precision) || ')', '')
    || (case is_nullable when 'NO' then ' NOT NULL' else '' end)
    || (case when column_default is not null then ' DEFAULT ' || column_default else '' end)
    || ';' as "AddColumn"

from information_schema.columns

where table_name = 'stocks' -- imagine ;-)
    --and table_schema ilike 'schema'
    --and column_name not in ('column')

order by table_schema, table_name
    --, ordinal_position
    , column_name
