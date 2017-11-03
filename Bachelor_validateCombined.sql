CREATE OR REPLACE FUNCTION topology.validateCombined(topology text,tablename character varying,attribute character varying,criterium character varying,elementid int,typeid int)
RETURNS boolean
AS
$func$
DECLARE
	SQL text;
	validation boolean;
	SQL2 text;
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
	
	SQL2 = 'SELECT ((SELECT ' || attribute || ' FROM ' || topology || '.' || tablename || ' WHERE system_id = (SELECT id FROM temp_ WHERE t_name = ''' || tablename || ''')) = ''' || criterium || ''');';
	EXECUTE SQL2 into validation;

	IF(validation IS NOT TRUE)THEN
		return false;
	END IF;
		
	return validation as validation;
END
$func$ LANGUAGE plpgsql;

SELECT topology.validateCombined('gas_test','absperrarmatur','armaturenstellung','geschlossen',1000338,1)