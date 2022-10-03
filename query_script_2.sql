DROP VIEW urban_features1, urban_landuse_landcover;
DROP TABLE urban_landuse_landcover_table;

DROP VIEW buildings;
CREATE OR REPLACE VIEW buildings AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'building'::varchar(30) AS feature,
	tags->>'building'::varchar(30) AS type,
	''::varchar(30) AS material,
	tags->>'height' AS size, --has feet and meter, a bit of a mess tbh, do not use
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'building' <>''
	;
	
DROP VIEW lf_roads;
CREATE OR REPLACE VIEW lf_roads AS
SELECT (row_number() OVER ())::int AS sid, way_id::varchar(20), 
feature::varchar(30), type::varchar(30), material::varchar(30), 
CASE
WHEN size = '22' THEN '2'
WHEN size = '2;1' THEN '1'
WHEN size = '2; 1' THEN '1'
WHEN size = '2;3' THEN '2'
WHEN size = '10' THEN '1'
WHEN size = '1; 2' THEN '1'
WHEN size = '1;2' THEN '1'
ELSE size
END::numeric(3,1) AS size, (geom)::geometry(LineString, 3857) AS geom
FROM
(
SELECT way_id, feature, type, material,
	REPLACE(size, '-', '') AS size,
 geom
FROM
(
SELECT way_id,  
	'linear_feature' AS feature,
	tags->>'highway' AS type,
	tags->>'surface' AS material,
	tags ->> 'lanes' AS size,
	geom AS geom
    FROM lines WHERE tags->>'highway' <>''
		) t1
	) t2
	;

DROP VIEW lf_rails;
CREATE OR REPLACE VIEW lf_rails AS
SELECT (row_number() OVER ())::int AS sid, way_id::varchar(20), 
feature::varchar(30), type::varchar(30), material::varchar(30), 
CASE
WHEN type = 'rail' THEN 2
WHEN type = 'proposed' THEN 0
ELSE 1
END::smallint AS size, (geom)::geometry(LineString, 3857) AS geom
FROM
(
SELECT way_id, feature, type, material,
	REPLACE(size, '-', '') AS size,
 geom
FROM
(
SELECT way_id,  
	'linear_feature_rail' AS feature,
	tags->>'railway' AS type,
	'' AS material,
	'' AS size,
	geom  AS geom
    FROM lines WHERE tags->>'railway' NOT IN ('monorail','funicular','subway') or tags->> 'landuse' = 'railway'
		) t1
	) t2
	;

DROP VIEW open_green;
CREATE OR REPLACE VIEW open_green AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'open_green_area'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'natural'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse' IN ('grass', 'cemetery', 'greenfield', 'recreation_ground',  'winter_sports','brownfield', 'construction') or tags ->> 'natural' IN ('tundra') or tags->> 'golf'<>'rough'
	;

DROP VIEW hetero_green;
CREATE OR REPLACE VIEW hetero_green AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'hetero_green_area'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'natural'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'natural'IN('garden', 'scrub', 'sand', 'shrub') or  tags->> 'landuse'IN('plant_nursery', 'meadow',  'flowerbed') or tags->> 'meadow'<>'' or tags->> 'golf' = 'rough'
	;
	
DROP VIEW dense_green;
CREATE OR REPLACE VIEW dense_green AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'dense_green_area'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'leaf_type'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'IN('forest') or tags->>'natural'='wood' or tags ->> 'boundary' = 'forest'
	;

DROP VIEW resourceful_green;
CREATE OR REPLACE VIEW resourceful_green AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'resourceful_green_area'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'natural'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse' IN ('orchard','farmland', 'landfill','vineyard', 'farmyard','allotments')
	;

DROP VIEW water;
CREATE OR REPLACE VIEW water AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'water'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'water'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'='basin' or tags ->> 'natural' IN ('water', 'wetland') or tags ->> 'water' <>''
	;

DROP VIEW parking_surface;
CREATE OR REPLACE VIEW parking_surface AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'parking_surface'::varchar(30) AS feature,
	tags->>'amenity'::varchar(30) AS type,
	''::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'parking'='surface'
	;

DROP VIEW residential;
CREATE OR REPLACE VIEW residential AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'residential'::varchar(30) AS feature,
	tags->>'residential'::varchar(30) AS type,
	''::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'='residential'
	;
	
DROP VIEW commercial_industrial;
CREATE OR REPLACE VIEW commercial_industrial AS
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'commercial_industrial'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30) AS type,
	tags->>'retail'::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'IN('commercial',  'retail', 'industrial')
	;

DROP VIEW institutional;
CREATE OR REPLACE VIEW institutional AS	
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'institutional'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30)  AS type,
	''::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'IN('institutional',  'education', 'religious')
	;
DROP VIEW barrier;
CREATE OR REPLACE VIEW barrier AS	
SELECT (row_number() OVER ())::int AS sid, way_id::varchar(20),  
	'barrier'::varchar(30) AS feature,
	tags->>'barrier'::varchar(30)  AS type,
	tags->>'fence_type'::varchar(30) AS material,
	tags->>'height'::varchar(30) AS size,
	geom AS geom
    FROM lines WHERE tags->>'barrier'<>''
	;

DROP VIEW landuse_park;
CREATE OR REPLACE VIEW landuse_park AS	
SELECT (row_number() OVER ())::int AS sid, area_id::varchar(20),  
	'institutional'::varchar(30) AS feature,
	tags->>'landuse'::varchar(30)  AS type,
	''::varchar(30) AS material,
	'' AS size,
	st_multi(geom)::geometry('MultiPolygon', 3857)  AS geom
    FROM polygons WHERE tags->>'landuse'IN('park', 'nature_reserve', 'natural_reserve', 'landscape_reserve') or tags ->> 'amenity' = 'park' or tags ->> 'leisure' IN ('park', 'nature_riserve', 'golf_course') or tags->> 'boundary'='protected_area'
	;

DROP VIEW background_layer3;
CREATE OR REPLACE VIEW background_layer3 AS	
SELECT (row_number() OVER ())::int AS sid, relation_id::varchar(20),  
	'background'::varchar(30) AS feature,
	tags->>'name'::varchar(30)  AS type,
	tags ->> 'admin_level'::varchar(30) AS material,
	'' AS size,
	st_multi(ST_BuildArea(geom))::geometry(Multipolygon, 3857) AS geom
	FROM boundaries WHERE tags->> 'boundary'IN('administrative')
	;

-- UNion all geometry
CREATE TABLE urban_features1 AS
-- water
(SELECT sid, area_id as osm_id, feature, type, material, size, 1::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM water
)
UNION ALL
--barrier
(SELECT sid, way_id as osm_id, feature, type, material, size, 2::smallint AS priority, st_multi(st_buffer(geom, 1))::geometry('MultiPolygon', 3857) FROM barrier
)
UNION ALL
--railways
(SELECT sid, way_id as osm_id, feature, type, material, size::varchar(10), 3::smallint AS priority, st_multi(st_buffer(geom, 2*size))::geometry('MultiPolygon', 3857) FROM lf_rails
)
UNION ALL
--roads
(SELECT sid, way_id as osm_id, feature, type, material, size::varchar(10), 4::smallint AS priority, st_multi(st_buffer(geom, 5*size))::geometry('MultiPolygon', 3857) FROM lf_roads
)
UNION ALL
-- parking_surface
(SELECT sid, area_id as osm_id, feature, type, material, size, 5::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM parking_surface
)
UNION ALL
--buildings
(SELECT sid, area_id as osm_id, feature, type, material, size, 6::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM buildings
);

--Landuse_landcover lazer
-- CREATE OR REPLACE VIEW urban_landuse_landcover AS
CREATE TABLE urban_landuse_landcover_table AS
-- resourceful_green
(SELECT sid, area_id as osm_id, feature, type, material, size, 7::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM resourceful_green
)
UNION ALL
-- dense_green
(SELECT sid, area_id as osm_id, feature, type, material, size, 8::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM dense_green
)
UNION ALL
-- hetero_green
(SELECT sid, area_id as osm_id, feature, type, material, size, 9::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM hetero_green
)
UNION ALL
-- open_green
(SELECT sid, area_id as osm_id, feature, type, material, size, 10::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM open_green
)
UNION ALL
--landuse_park
(SELECT sid, area_id as osm_id, feature, type, material, size, 11::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM landuse_park
)
UNION ALL
-- residential
(SELECT sid, area_id as osm_id, feature, type, material, size, 12::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM residential
)
UNION ALL
--institutional
(SELECT sid, area_id as osm_id, feature, type, material, size, 13::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM institutional
)
UNION ALL
-- commercial_industrial
(SELECT sid, area_id as osm_id, feature, type, material, size, 14::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM commercial_industrial
)
UNION ALL
--background_layer3
(SELECT sid, relation_id as osm_id, feature, type, material, size, 15::smallint AS priority, geom::geometry('MultiPolygon', 3857) FROM background_layer3
);

	
