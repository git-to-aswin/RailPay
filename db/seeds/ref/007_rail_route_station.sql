-- Seed ref.rail_route_stations for a subset of routes using existing ref.stations rows
-- Uses MIN(id) per station_name to avoid duplicates from overlap stations (e.g., Sunshine).
-- Source station ids/names are from your exported ref.stations query output.  [oai_citation:1‡stations_202601201351.json](sediment://file_00000000d55c7206942bc26c51895f3b)

WITH
r AS (
  SELECT route_id::int AS route_id, route_name
  FROM ref.rail_routes
),
s AS (
  SELECT station_name, MIN(id)::smallint AS station_id
  FROM ref.stations
  GROUP BY station_name
),
seed(route_name, station_name, stop_sequence) AS (
  VALUES
    -------------------------------------------------------------------------
    -- Ballarat Line (subset)
    -------------------------------------------------------------------------
    ('Ballarat Line', 'Southern Cross',     1),
    ('Ballarat Line', 'Footscray',          2),
    ('Ballarat Line', 'Sunshine',           3),
    ('Ballarat Line', 'Deer Park',          4),
    ('Ballarat Line', 'Ardeer',             5),
    ('Ballarat Line', 'Caroline Springs',   6),
    ('Ballarat Line', 'Rockbank',           7),
    ('Ballarat Line', 'Melton',             8),
    ('Ballarat Line', 'Cobblebank',         9),
    ('Ballarat Line', 'Bacchus Marsh',     10),
    ('Ballarat Line', 'Ballan',            11),
    ('Ballarat Line', 'Ballarat',          12),
    ('Ballarat Line', 'Wendouree',         13),
    -------------------------------------------------------------------------
    -- Bendigo Line (subset)
    -------------------------------------------------------------------------
    ('Bendigo Line', 'Southern Cross',      1),
    ('Bendigo Line', 'Footscray',           2),
    ('Bendigo Line', 'Sunshine',            3),
    ('Bendigo Line', 'Sunbury',             4),
    ('Bendigo Line', 'Clarkefield',         5),
    ('Bendigo Line', 'Riddells Creek',      6),
    ('Bendigo Line', 'Gisborne',            7),
    ('Bendigo Line', 'Macedon',             8),
    ('Bendigo Line', 'Woodend',             9),
    ('Bendigo Line', 'Kyneton',            10),
    ('Bendigo Line', 'Malmsbury',          11),
    ('Bendigo Line', 'Castlemaine',        12),
    ('Bendigo Line', 'Kangaroo Flat',      13),
    ('Bendigo Line', 'Bendigo',            14),
    ('Bendigo Line', 'Epsom',              15),
    ('Bendigo Line', 'Eaglehawk',          16),
    ('Bendigo Line', 'Huntly',             17),
    ('Bendigo Line', 'Goornong',           18),
    ('Bendigo Line', 'Raywood',            19),
    -------------------------------------------------------------------------
    -- Geelong Line (subset via RRL corridor)
    -------------------------------------------------------------------------
    ('Geelong Line', 'Southern Cross',      1),
    ('Geelong Line', 'Footscray',           2),
    ('Geelong Line', 'Sunshine',            3),
    ('Geelong Line', 'Deer Park',           4),
    ('Geelong Line', 'Tarneit',             5),
    ('Geelong Line', 'Wyndham Vale',        6),
    ('Geelong Line', 'Little River',        7),
    ('Geelong Line', 'Lara',                8),
    ('Geelong Line', 'Corio',               9),
    ('Geelong Line', 'North Shore',        10),
    ('Geelong Line', 'North Geelong',      11),
    ('Geelong Line', 'Geelong',            12),
    ('Geelong Line', 'South Geelong',      13),
    ('Geelong Line', 'Marshall',           14),
    ('Geelong Line', 'Waurn Ponds',        15),
    -------------------------------------------------------------------------
    -- Gippsland Line (subset)
    -------------------------------------------------------------------------
    ('Gippsland Line', 'Southern Cross',     1),
    ('Gippsland Line', 'Richmond',           2),
    ('Gippsland Line', 'Caulfield',          3),
    ('Gippsland Line', 'Clayton',            4),
    ('Gippsland Line', 'Dandenong',          5),
    ('Gippsland Line', 'Berwick',            6),
    ('Gippsland Line', 'Pakenham',           7),
    ('Gippsland Line', 'Tynong',             8),
    ('Gippsland Line', 'Bunyip',             9),
    ('Gippsland Line', 'Longwarry',         10),
    ('Gippsland Line', 'Drouin',            11),
    ('Gippsland Line', 'Warragul',          12),
    ('Gippsland Line', 'Yarragon',          13),
    ('Gippsland Line', 'Trafalgar',         14),
    ('Gippsland Line', 'Moe',               15),
    ('Gippsland Line', 'Morwell',           16),
    ('Gippsland Line', 'Traralgon',         17),
    ('Gippsland Line', 'Sale',              18),
    ('Gippsland Line', 'Bairnsdale',        19),
    -------------------------------------------------------------------------
    -- Seymour Line (subset)
    -------------------------------------------------------------------------
    ('Seymour Line', 'Southern Cross',       1),
    ('Seymour Line', 'North Melbourne',      2),
    ('Seymour Line', 'Broadmeadows',         3),
    ('Seymour Line', 'Craigieburn',          4),
    ('Seymour Line', 'Donnybrook',           5),
    ('Seymour Line', 'Wallan',               6),
    ('Seymour Line', 'Wandong',              7),
    ('Seymour Line', 'Heathcote Junction',   8),
    ('Seymour Line', 'Kilmore East',         9),
    ('Seymour Line', 'Seymour',             10)
)
INSERT INTO ref.rail_route_stations (route_id, station_id, stop_sequence)
SELECT
  r.route_id,
  s.station_id,
  seed.stop_sequence
FROM seed
JOIN r ON r.route_name = seed.route_name
JOIN s ON s.station_name = seed.station_name
ON CONFLICT DO NOTHING;