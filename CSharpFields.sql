/*
 * Auxiliar para crear Mapa y Propiedades en XML y Clase, respectivamente.
 */

select format('%s.%s.%s', table_schema, table_name, column_name) as "Column", data_type
    , replace(initcap(replace(column_name, '_', ' ')), ' ', '') as "Pascal Case"
    , lower(substring(replace(initcap(replace(column_name, '_', ' ')), ' ', ''), 1, 1)) || substring(replace(initcap(replace(column_name, '_', ' ')), ' ', ''), 2) as "Camel Case"

    , format('<property name="%s" column="%s"%s />', replace(initcap(column_name), '_', ''), column_name
        , case upper(is_nullable) when 'NO' then ' not-null="true"' else '' end)
        as "NHibernate Map Field"

    , format(E'/// <summary>\n/// %s\n/// </summary>\npublic virtual %s%s %s { get; set; }\n'
        , coalesce(trim(pgd.description), '')
        , case
            when upper(data_type) = 'BOOLEAN' then 'bool'
            when upper(data_type) in ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') then 'DateTime'
            when upper(data_type) in ('INTEGER', 'SMALLINT') then 'int'
            when upper(data_type) in ('NUMERIC') then 'decimal'
            when upper(data_type) in ('UUID') then 'Guid'
            when upper(data_type) in ('TEXT', 'CHARACTER', 'CHARACTER VARYING') then 'string'
            else ''
            end
        , case when upper(data_type) IN ('TEXT', 'CHARACTER VARYING') then '' else '?' end
        , replace(initcap(column_name), '_', ''))
        as "Auto-Property Entity"

from information_schema.columns as c
inner join pg_catalog.pg_description as pgd ON pgd.objsubid = c.ordinal_position
inner join pg_catalog.pg_statio_all_tables as st ON pgd.objoid = st.relid and c.table_schema = st.schemaname and c.table_name = st.relname

where table_name ilike 'stocks' -- imagine ;-)
    --and table_schema ilike 'schema'

order by table_schema, table_name
    --, ordinal_position
    , column_name
