/*
 * Gets script for add columns.
 */

select format('%s.%s.%s', table_schema, table_name, column_name) as "Column"
    , format('ALTER TABLE %s.%s ADD COLUMN %s %s', table_schema, table_name, column_name, upper(data_type))
        || coalesce(' (' || coalesce(character_maximum_length, numeric_precision, datetime_precision) || ')', '')
        || (case is_nullable when 'NO' then ' NOT NULL' else '' end)
        || (case when column_default is not null then ' DEFAULT ' || column_default else '' end)
        || ';' as "AddColumn"
    , format(E'COMMENT ON COLUMN %s.%s.%s IS \'%s\';', c.table_schema, c.table_name, c.column_name
        , coalesce(trim(pgd.description), ''))
        as "SetComment"

from information_schema.columns c
inner join pg_catalog.pg_description as pgd ON pgd.objsubid = c.ordinal_position
inner join pg_catalog.pg_statio_all_tables as st ON pgd.objoid = st.relid and c.table_schema = st.schemaname and c.table_name = st.relname


where table_name = 'stocks' -- imagine ;-)
    --and table_schema ilike 'schema'
    --and column_name not in ('column')

order by table_schema, table_name
    --, ordinal_position
    , column_name
