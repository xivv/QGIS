

-- Create the topology with the name and the SRID
SELECT CreateTopology('gas_simulation',31468);

-- Import the edge/node data into the topology
INSERT INTO gas_simulation.node SELECT node_id[3], 0, ST_SETSRID(ST_MakePoint(coord[1] * 0.001, coord[2] * 0.001),31468) from ga.sw_gis_node;
INSERT INTO gas_simulation.edge_data SELECT link_id[3], first_node_id[3], last_node_id[3], link_id[3],link_id[3],link_id[3],link_id[3],0,0, 
 ST_SETSRID(ST_MakeLine(ST_MakePoint(coord_1[1] * 0.001, coord_1[2] * 0.001), ST_MakePoint(coord_2[1] * 0.001, coord_2[2] * 0.001)),31468) from ga.sw_gis_link 

-- Get the table absperrarmatur from the original swm data
CREATE TABLE gas_simulation.absperrarmatur AS TABLE ga.g_absperrarmatur;

-- Add a topogeom column
SELECT AddTopoGeometryColumn('gas_simulation', 'gas_simulation', 'absperrarmatur', 'g', 'POINT');

-- Update the column with 
UPDATE gas_simulation.absperrarmatur t SET g = CreateTopoGeom('gas_simulation',1,1,CAST ('{{' || (SELECT k.node_id[3]) || ',1}}' AS integer[])) FROM ga.sw_gis_point k where k.rwo_id = t.rwo_id and k.app_code = 1;

-- Add missing system_id to the absperrarmatur table
ALTER TABLE gas_simulation.absperrarmatur ADD COLUMN system_id INTEGER;
CREATE SEQUENCE gas_simulation.test_id_seq OWNED by gas_simulation.absperrarmatur.system_id;
ALTER TABLE gas_simulation.absperrarmatur ALTER COLUMN system_id SET DEFAULT nextval('gas_simulation.test_id_seq');
UPDATE gas_simulation.absperrarmatur SET system_id = nextval('gas_simulation.test_id_seq');

-- OPTIONAL --

INSERT INTO gas_simulation.absperrarmatur (g,armaturenstellung) VALUES(CreateTopoGeom('gas_simulation',1,1,'{{437082429,1}}'),'geschlossen');
INSERT INTO gas_simulation.absperrarmatur (g,armaturenstellung) VALUES(CreateTopoGeom('gas_simulation',1,1,'{{11865607,1}}'),'geschlossen');
