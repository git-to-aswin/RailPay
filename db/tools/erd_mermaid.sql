-- Outputs Mermaid "erDiagram" text to STDOUT.
-- Includes tables + columns + PK marker, and FK relationships.
-- Filters to your app schemas only.

\set QUIET 1
\pset pager off
\pset tuples_only on
\pset format unaligned

SELECT 'erDiagram';

-- 1) Tables + columns
WITH cols AS (
  SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
    EXISTS (
      SELECT 1
      FROM pg_index i
      JOIN pg_attribute ia
        ON ia.attrelid = i.indrelid
       AND ia.attnum = ANY(i.indkey)
      WHERE i.indrelid = c.oid
        AND i.indisprimary
        AND ia.attname = a.attname
    ) AS is_pk
  FROM pg_attribute a
  JOIN pg_class c ON c.oid = a.attrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE a.attnum > 0
    AND NOT a.attisdropped
    AND c.relkind IN ('r','p')  -- r=table, p=partitioned table
    AND n.nspname NOT IN ('pg_catalog','information_schema')
    AND n.nspname NOT LIKE 'pg_toast%'
    AND n.nspname NOT LIKE 'pg_temp%'
),
tables AS (
  SELECT DISTINCT schema_name, table_name
  FROM cols
)
SELECT
  format(
    E'\n%s {\n%s\n}',
    -- Mermaid entity name: schema_table (avoid dots)
    replace(schema_name || '.' || table_name, '.', '_'),
    string_agg(
      format(
        '  %s %s%s',
        regexp_replace(data_type, '\s+', '_', 'g'),
        column_name,
        CASE WHEN is_pk THEN ' PK' ELSE '' END
      ),
      E'\n'
      ORDER BY column_name
    )
  )
FROM cols
GROUP BY schema_name, table_name
ORDER BY schema_name, table_name;

-- 2) Relationships (FKs)
WITH fks AS (
  SELECT
    ns_src.nspname AS src_schema,
    src.relname    AS src_table,
    ns_tgt.nspname AS tgt_schema,
    tgt.relname    AS tgt_table,
    con.conname    AS fk_name
  FROM pg_constraint con
  JOIN pg_class src ON src.oid = con.conrelid
  JOIN pg_namespace ns_src ON ns_src.oid = src.relnamespace
  JOIN pg_class tgt ON tgt.oid = con.confrelid
  JOIN pg_namespace ns_tgt ON ns_tgt.oid = tgt.relnamespace
  WHERE con.contype = 'f'
    AND ns_src.nspname NOT IN ('pg_catalog','information_schema')
    AND ns_src.nspname NOT LIKE 'pg_toast%'
    AND ns_src.nspname NOT LIKE 'pg_temp%'
    AND ns_tgt.nspname NOT IN ('pg_catalog','information_schema')
    AND ns_tgt.nspname NOT LIKE 'pg_toast%'
    AND ns_tgt.nspname NOT LIKE 'pg_temp%'
)
SELECT
  format(
    '%s }o--|| %s : "%s"',
    replace(src_schema || '.' || src_table, '.', '_'),
    replace(tgt_schema || '.' || tgt_table, '.', '_'),
    fk_name
  )
FROM fks
ORDER BY src_schema, src_table, tgt_schema, tgt_table, fk_name;
