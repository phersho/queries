/*
 * Auxiliar para crear Mapa y Propiedades en XML y Clase, respectivamente.
 */

SELECT column_name AS "Column", data_type
    , REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '') AS "Pascal Case"
    , LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 1, 1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2) AS "Camel Case"

-- HBM
    , '<property name="' || REPLACE(INITCAP(column_name), '_', '') || '" column="' || column_name || '"'
        || CASE UPPER(is_nullable) WHEN 'NO' THEN ' not-null="true"' ELSE '' END
        || CASE
            WHEN UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1 THEN ' type="StringBoolean"'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN ' type="Timestamp"'
            ELSE '' END
        || ' />'
	AS "A2 Entity.Map"

-- Entity A2
	, E'/// <summary>\n/// '
        --|| pgd.description -- para comentarios de la columna en la base de datos
        || E'\n/// </summary>\n'
        || 'public virtual '
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'int'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'decimal'
            WHEN UPPER(data_type) IN ('UUID') THEN 'Guid'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'string'
            ELSE ''
            END
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE '?' END
        || ' ' || REPLACE(INITCAP(column_name), '_', '') 
        || E' { get; set; }\n'
        AS "A2 Entity.Property"

    , '.ForMember(dst => dst.' || REPLACE(INITCAP(column_name), '_', '') 
        || ', opt=> opt.MapFrom(src => src.' || REPLACE(INITCAP(column_name), '_', '') 
        || '))'
        AS "A2 Entity.Clone::AutoMapper.Member"

-- Entity A1
    , E'/// <sumary>\n///\n/// </summary>\nprivate '
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'int'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'decimal'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'string'
            ELSE ''
            END
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE '?' END
        || ' ' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 1, 1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2) || E';\n'
        || 'private '
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'int'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'decimal'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'string'
            ELSE ''
            END
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE '?' END
        || ' ' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 1, 1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2) || E'_Old;\n'
        AS "A1 Entity.Field"

    , E'/// <sumary>\n///\n/// </summary>\n[EntityField]\npublic '
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'int'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'decimal'
            WHEN UPPER(data_type) IN ('UUID') THEN 'Guid'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'string'
            ELSE ''
            END
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE '?' END
        || ' ' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '')
        || E'\n{\nget { return this.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 1, 1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || E'; }\nset\n{\nthis.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 1, 1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || E' = value;\nthis.OnModification(this, null);\n}\n}\n'
        AS "A1 Entity.Property"

    , E'/// <sumary>\n///\n/// </summary>\n[EntityField]\npublic '
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'int'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'decimal'
            WHEN UPPER(data_type) IN ('UUID') THEN 'Guid'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'string'
            ELSE ''
            END
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE '?' END
        || ' ' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '')
        || E' { get; set; }\n'
        AS "A1 Entity.SingleProperty"

    , E'this.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''),1,1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || '_Old = this.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''),1,1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || ';'
        AS "A1 Entity.Commit"

    , E'this.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''),1,1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || ' = this.' || LOWER(SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''),1,1)) || SUBSTRING(REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', ''), 2)
        || '_Old;'
        AS "A1 Entity.Rollback"

    , E'[DAOField]\npublic string GetNameField' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '')
        || ' { get { return "' || column_name || '"; } }'
        AS "A1 DAO.NameField"

    , E'this.BindedFields[this.GetNameField' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '')
        || '] = this.Entity.' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '') || ';'
        AS "A1 DAO.BindDataFields"

    , 'this.Entity.' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '') || ' = SqlHelper.Field'
        || CASE WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER VARYING') THEN '' ELSE 'Nullable' END
        || CASE
            WHEN UPPER(data_type) = 'BOOLEAN' OR (UPPER(data_type) = 'CHARACTER VARYING' AND character_maximum_length = 1) THEN 'Bool'
            WHEN UPPER(data_type) IN ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITHOUT TIME ZONE') THEN 'DateTime'
            WHEN UPPER(data_type) IN ('INTEGER', 'SMALLINT') THEN 'Int32'
            WHEN UPPER(data_type) IN ('NUMERIC') THEN 'Decimal'
            WHEN UPPER(data_type) IN ('TEXT', 'CHARACTER', 'CHARACTER VARYING') THEN 'String'
            ELSE ''
            END
        || 'Value(this.GetNameField' || REPLACE(INITCAP(REPLACE(column_name, '_', ' ')), ' ', '') || ');'
        AS "A1 DAO.FillObjectData"

FROM information_schema.columns AS c

-- para obtener los comentarios
--INNER JOIN pg_catalog.pg_description AS pgd ON pgd.objsubid = c.ordinal_position
--INNER JOIN pg_catalog.pg_statio_all_tables AS st ON pgd.objoid = st.relid AND c.table_schema = st.schemaname AND c.table_name = st.relname

WHERE table_name ILIKE 'table_name' -- utilizar su imaginación ;-)

ORDER BY column_name
