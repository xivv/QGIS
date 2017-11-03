DROP FUNCTION topology.getBetriebsmittelValidate(topology text,tablename text,elementid int,typeid int);
CREATE OR REPLACE FUNCTION topology.getBetriebsmittelValidate(topology text,tablename text,elementid int,typeid int)
RETURNS TABLE (
id int,
s_name character varying,
t_name character varying
) AS
$func$
DECLARE
	SQL text;
	SQL_DYNAMIC text = 'SELECT r.topogeo_id,l.table_name,l.feature_column FROM '|| topology||'.relation r,topology.layer l WHERE l.table_name = ''' || tablename ||''' and r.element_id = '|| elementid ||' and r.element_type = '|| typeid ||' and l.layer_id = r.layer_id and l.schema_name = '''|| topology ||'''';
	my_record RECORD;
BEGIN

	 CREATE TEMPORARY TABLE IF NOT EXISTS temp_
	(
	id int,
	s_name character varying,
	t_name character varying
	) ON COMMIT DELETE ROWS;

	TRUNCATE temp_;
   
	FOR my_record IN EXECUTE SQL_DYNAMIC
	LOOP 
		SQL = 'INSERT INTO temp_ VALUES((SELECT system_id FROM ' || topology || '.' || my_record.table_name || ' WHERE id(' || my_record.feature_column ||' ) = ' || my_record.topogeo_id || '),''' ||  topology || ''',''' ||  my_record.table_name || ''')';
		EXECUTE SQL;
	END LOOP;   

	RETURN QUERY SELECT * FROM temp_;
END
$func$ LANGUAGE plpgsql;
