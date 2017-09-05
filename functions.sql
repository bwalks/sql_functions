-- Allows for finding the tables with the highest memory usage
-- Can be called by `select * from top_tables_by_memory(10)`

CREATE FUNCTION top_tables_by_memory (limit_value integer default 20) 
RETURNS TABLE (relation text, total_size text) AS $$
  SELECT nspname || '.' || relname AS "relation",
      pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
    FROM pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
    WHERE nspname NOT IN ('pg_catalog', 'information_schema')
      AND C.relkind <> 'i'
      AND nspname !~ '^pg_toast'
    ORDER BY pg_total_relation_size(C.oid) DESC
    LIMIT limit_value;
$$ LANGUAGE sql;

-- Allows for checking if a bitstring has a specific bit set. Bit position is counted from the left
-- Can be used on a bitstring of any length. 
-- Can be called by `bit_field &>> 3` or `has_bit(bit_field, 3)`
CREATE FUNCTION has_bit (a bit varying, b integer) 
RETURNS boolean AS $$ 
  SELECT (b < bit_length(a)) AND ((a & (repeat('0', b) || '1' || repeat('0', bit_length(a) - (b + 1)))::bit varying) != repeat('0', bit_length(a))::bit varying);
$$ LANGUAGE sql;
CREATE OPERATOR &>> (leftarg = bit varying, rightarg = integer, procedure = has_bit);
