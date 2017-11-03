DROP FUNCTION topology.validateAttributeBool(topology text,tablename character varying,attribute character varying,criterium character varying,elementid int,typeid int);
CREATE OR REPLACE FUNCTION topology.validateAttributeBool(topology text,tablename character varying,attribute character varying,criterium character varying,elementid int,typeid int)
RETURNS boolean
AS
$func$
DECLARE
	SQL text;
	validation boolean;
BEGIN
	SQL = 'SELECT ((SELECT ' || attribute || ' FROM ' || topology || '.' || tablename || ' WHERE system_id = (SELECT id FROM topology.getBetriebsmittelValidate(''' || topology || ''',''' || tablename || ''',' || elementid || ',' || typeid || ') WHERE t_name = ''' || tablename || ''')) = ''' || criterium || ''');';
	EXECUTE SQL into validation;

	IF(validation IS NOT TRUE)THEN
		return false;
	END IF;
		
	return validation as validation;
END
$func$ LANGUAGE plpgsql;

SELECT topology.validateAttributeBool('gas_test','absperrarmatur','armaturenstellung','geschlossen',1000338,1);