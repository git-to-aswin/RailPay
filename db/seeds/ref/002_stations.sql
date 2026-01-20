INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at)
VALUES
  -- Metro core examples shown on the map
  (1001, 'Southern Cross', 1, NOW(), NOW()),
  (1002, 'Flinders Street', 1, NOW(), NOW()),
  (1003, 'Richmond', 1, NOW(), NOW()),
  (1004, 'North Melbourne', 1, NOW(), NOW()),
  (1005, 'Footscray', 1, NOW(), NOW()),
  (1006, 'Essendon', 1, NOW(), NOW()),
  (1007, 'Caulfield', 1, NOW(), NOW()),
  -- Overlap 1/2
  (1008, 'Sunshine', 1, NOW(), NOW()),
  -- Zone 2 (metro / fringe)
  (1009, 'Deer Park', 2, NOW(), NOW()),
  (1010, 'Ardeer', 2, NOW(), NOW()),
  (1011, 'Caroline Springs', 2, NOW(), NOW()),
  (1012, 'Rockbank', 2, NOW(), NOW()),
  (1013, 'Melton', 2, NOW(), NOW()),
  (1014, 'Cobblebank', 2, NOW(), NOW()),
  (1015, 'Tarneit', 2, NOW(), NOW()),
  (1016, 'Wyndham Vale', 2, NOW(), NOW()),
  (1017, 'Little River', 2, NOW(), NOW()),
  (1018, 'Sunbury', 2, NOW(), NOW()),
  (1019, 'Watergardens', 2, NOW(), NOW()),
  (1020, 'Clarkefield', 2, NOW(), NOW()),
  (1021, 'Craigieburn', 2, NOW(), NOW()),
  (1022, 'Broadmeadows', 2, NOW(), NOW()),
  (1023, 'Donnybrook', 2, NOW(), NOW()),
  (1024, 'Wallan', 2, NOW(), NOW()),
  (1025, 'Wandong', 2, NOW(), NOW()),
  (1026, 'Heathcote Junction', 2, NOW(), NOW()),
  (1027, 'Dandenong', 2, NOW(), NOW()),
  (1028, 'Clayton', 2, NOW(), NOW()),
  (1029, 'Pakenham', 2, NOW(), NOW()),
  (1030, 'Berwick', 2, NOW(), NOW()),
  -- Overlaps 2/3 and 2/3/4
  (1031, 'Bacchus Marsh', 2, NOW(), NOW()),
  (1032, 'Riddells Creek', 2, NOW(), NOW()),
  (1033, 'Lara', 2, NOW(), NOW()),
  -- Overlaps 3/4
  (1034, 'Gisborne', 3, NOW(), NOW()),
  (1035, 'Macedon', 3, NOW(), NOW()),
  (1036, 'North Shore', 3, NOW(), NOW()),
  (1037, 'Corio', 3, NOW(), NOW()),
  (1038, 'North Geelong', 3, NOW(), NOW()),
  (1039, 'Kilmore East', 3, NOW(), NOW()),
  (1040, 'Tynong', 3, NOW(), NOW()),
  -- Zone 4 and overlaps 4/5
  (1041, 'Geelong', 4, NOW(), NOW()),
  (1042, 'South Geelong', 4, NOW(), NOW()),
  (1043, 'Marshall', 4, NOW(), NOW()),
  (1044, 'Waurn Ponds', 4, NOW(), NOW()),
  (1045, 'Ballan', 4, NOW(), NOW()),
  (1046, 'Woodend', 4, NOW(), NOW()),
  (1047, 'Broadford', 4, NOW(), NOW()),
  (1048, 'Garfield', 4, NOW(), NOW()),
  (1049, 'Bunyip', 4, NOW(), NOW()),
  -- Overlaps 5/6
  (1050, 'Tallarook', 5, NOW(), NOW()),
  (1051, 'Longwarry', 5, NOW(), NOW()),
  -- Zone 6 and overlap 6/7
  (1052, 'Seymour', 6, NOW(), NOW()),
  (1053, 'Drouin', 6, NOW(), NOW()),
  (1054, 'Kyneton', 6, NOW(), NOW()),
  (1055, 'Warragul', 6, NOW(), NOW()),
  -- Overlap 7/8
  (1056, 'Malmsbury', 7, NOW(), NOW()),
  -- Zone 8 and overlap 8/9
  (1057, 'Ballarat', 8, NOW(), NOW()),
  (1058, 'Wendouree', 8, NOW(), NOW()),
  (1059, 'Yarragon', 8, NOW(), NOW()),
  (1060, 'Trafalgar', 8, NOW(), NOW()),
  -- Zone 9 and overlap 9/10
  (1061, 'Castlemaine', 9, NOW(), NOW()),
  (1062, 'Moe', 9, NOW(), NOW()),
  (1063, 'Maryborough', 9, NOW(), NOW()),
  (1064, 'Winchelsea', 9, NOW(), NOW()),
  (1065, 'Colac', 9, NOW(), NOW()),
  (1066, 'Camperdown', 9, NOW(), NOW()),
  (1067, 'Warrnambool', 9, NOW(), NOW()),
  (1068, 'Ararat', 9, NOW(), NOW()),
  (1069, 'Echuca', 9, NOW(), NOW()),
  (1070, 'Shepparton', 9, NOW(), NOW()),
  (1071, 'Benalla', 9, NOW(), NOW()),
  (1072, 'Wangaratta', 9, NOW(), NOW()),
  (1073, 'Wodonga', 9, NOW(), NOW()),
  (1074, 'Swan Hill', 9, NOW(), NOW()),
  (1075, 'Sale', 9, NOW(), NOW()),
  (1076, 'Bairnsdale', 9, NOW(), NOW()),
  -- Zone 11/12
  (1077, 'Morwell', 11, NOW(), NOW()),
  (1078, 'Traralgon', 12, NOW(), NOW()),
  -- Zone 12/13 overlap + Zone 13
  (1079, 'Kangaroo Flat', 12, NOW(), NOW()),
  (1080, 'Bendigo', 13, NOW(), NOW()),
  (1081, 'Epsom', 13, NOW(), NOW()),
  (1082, 'Eaglehawk', 13, NOW(), NOW()),
  -- Zone 13/14 overlap
  (1083, 'Huntly', 13, NOW(), NOW()),
  (1084, 'Goornong', 13, NOW(), NOW()),
  -- Zone 15/16 overlap
  (1085, 'Raywood', 15, NOW(), NOW())
ON CONFLICT (station_id) DO UPDATE
SET station_name = EXCLUDED.station_name,
    zone_id      = EXCLUDED.zone_id,
    updated_at   = NOW();

-- Seed: Overlap zones for stations with multiple zones
INSERT INTO ref.stations (station_id, station_name, zone_id, created_at, updated_at)
VALUES
  -- Sunshine 1/2 (base row already has zone 1)
  (1008, 'Sunshine', 2, NOW(), NOW()),
  -- Bacchus Marsh 2/3 (base row already has zone 2)
  (1031, 'Bacchus Marsh', 3, NOW(), NOW()),
  -- Riddells Creek 2/3 (base row already has zone 2)
  (1032, 'Riddells Creek', 3, NOW(), NOW()),
  -- Lara 2/3/4 (base row already has zone 2)
  (1033, 'Lara', 3, NOW(), NOW()),
  (1033, 'Lara', 4, NOW(), NOW()),
  -- 3/4 overlaps (base rows already have zone 3)
  (1034, 'Gisborne', 4, NOW(), NOW()),
  (1035, 'Macedon', 4, NOW(), NOW()),
  (1036, 'North Shore', 4, NOW(), NOW()),
  (1037, 'Corio', 4, NOW(), NOW()),
  (1038, 'North Geelong', 4, NOW(), NOW()),
  (1039, 'Kilmore East', 4, NOW(), NOW()),
  (1040, 'Tynong', 4, NOW(), NOW()),
  -- 4/5 overlaps (base rows already have zone 4)
  (1045, 'Ballan', 5, NOW(), NOW()),
  (1046, 'Woodend', 5, NOW(), NOW()),
  (1047, 'Broadford', 5, NOW(), NOW()),
  (1048, 'Garfield', 5, NOW(), NOW()),
  (1049, 'Bunyip', 5, NOW(), NOW()),
  -- 5/6 overlaps (base rows already have zone 5)
  (1050, 'Tallarook', 6, NOW(), NOW()),
  (1051, 'Longwarry', 6, NOW(), NOW()),
  -- 6/7 overlaps (base rows already have zone 6)
  (1054, 'Kyneton', 7, NOW(), NOW()),
  (1055, 'Warragul', 7, NOW(), NOW()),
  -- 7/8 overlap (base row already has zone 7)
  (1056, 'Malmsbury', 8, NOW(), NOW()),
  -- 8/9 overlap (base row already has zone 8)
  (1060, 'Trafalgar', 9, NOW(), NOW()),
  -- 9/10 overlaps (base rows already have zone 9)
  (1061, 'Castlemaine', 10, NOW(), NOW()),
  (1062, 'Moe', 10, NOW(), NOW()),
  -- 12/13 overlap (base row already has zone 12)
  (1079, 'Kangaroo Flat', 13, NOW(), NOW()),
  -- 13/14 overlaps (base rows already have zone 13)
  (1083, 'Huntly', 14, NOW(), NOW()),
  (1084, 'Goornong', 14, NOW(), NOW()),
  -- 15/16 overlap (base row already has zone 15)
  (1085, 'Raywood', 16, NOW(), NOW())
ON CONFLICT (station_id, zone_id) DO NOTHING;