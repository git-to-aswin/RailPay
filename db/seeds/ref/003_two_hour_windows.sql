WITH mapping AS (
  SELECT 2::smallint AS z, INTERVAL '2 hours' AS w
  UNION ALL SELECT gs::smallint, INTERVAL '2 hours 30 minutes' FROM generate_series(3,5) gs
  UNION ALL SELECT gs::smallint, INTERVAL '3 hours'           FROM generate_series(6,8) gs
  UNION ALL SELECT gs::smallint, INTERVAL '3 hours 30 minutes' FROM generate_series(9,11) gs
  UNION ALL SELECT gs::smallint, INTERVAL '4 hours'           FROM generate_series(12,14) gs
  UNION ALL SELECT 15::smallint, INTERVAL '4 hours 30 minutes'
)
INSERT INTO ref.two_hour_windows (zone_count, time_window)
SELECT z, w
FROM mapping
ON CONFLICT (zone_count) DO UPDATE
SET time_window = EXCLUDED.time_window,
    updated_at  = NOW();