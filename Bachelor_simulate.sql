DROP FUNCTION topology.simulate(startnodes character varying,topology text,tablename character varying,attribute character varying,criterium character varying);
CREATE OR REPLACE FUNCTION topology.simulate(startnodes character varying,topology text,tablename character varying,attribute character varying,criterium character varying)
RETURNS TABLE (
edge_id integer,
start_node integer,
end_node integer
) AS
$func$
DECLARE
	SQL text;
BEGIN

	SQL = 'WITH RECURSIVE path AS (
	SELECT edge_id, start_node, end_node
	FROM ' || topology ||'.edge_data
	WHERE start_node = ANY (''{'|| startnodes || '}''::int[]) OR end_node = ANY (''{'|| startnodes || '}''::int[])
	UNION
	SELECT e.edge_id, e.start_node, e.end_node
	FROM ' || topology ||'.edge_data e, path s
	WHERE (s.start_node = e.start_node OR s.start_node = e.end_node OR s.end_node = e.end_node OR s.end_node = e.start_node)
	AND (SELECT * FROM topology.validateCombined(''' || topology || ''','''|| tablename ||''','''|| attribute ||''','''|| criterium ||''',e.start_node,1)) = false) 
	SELECT * FROM path;';

	RETURN QUERY EXECUTE SQL;
END
$func$ LANGUAGE plpgsql;

SELECT * FROM topology.simulate('1000338,11867303','gas_test','absperrarmatur','armaturenstellung','geschlossen');
