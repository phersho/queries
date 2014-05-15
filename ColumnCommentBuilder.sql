
/*
 * Crea los scripts de Comentarios de Columnas. Si no hay comentario, crea un script default
 * que establece el comentario en '.'.
 */

SELECT c.table_name AS "Table"
  , c.ordinal_position AS "Position"
  , c.column_name AS "Column"
  , col_description(T.typrelid, c.ordinal_position) AS "Description"
  , c.data_type AS "Type"
  , 'COMMENT ON COLUMN ' || c.table_name || '.' || c.column_name || ' IS '''
    || TRIM(COALESCE(col_description(T.typrelid, c.ordinal_position), ''))
    || CASE RIGHT(TRIM(COALESCE(col_description(T.typrelid, c.ordinal_position), '')), 1)
      WHEN '.' THEN ''
      ELSE '.'
      END
    || ''';' AS comment
  , right(c.column_name, 1)
FROM information_schema.columns c
INNER JOIN pg_catalog.pg_type T ON  T.typname = c.table_name
WHERE c.table_name ILIKE 'table_name' -- utilizar imaginación
ORDER BY c.table_name, c.ordinal_position
