-- Metro: Full fare (weekday caps)
-- Zone 1+2: 2-hour $5.70, daily cap $11.40
-- Zone 2-only: 2-hour $3.00, daily cap $6.00 (from your “excluding zone 1” table for 1 zone)
WITH metro_zone_mapping AS (
    -- Zone 1 only
    SELECT 1::SMALLINT AS zc, 570 AS bf, 1140 AS cf, TRUE AS iz1, FALSE AS iz2
    -- Zone 1 included
    UNION ALL SELECT 2::SMALLINT, 570, 1140, TRUE, FALSE
    UNION ALL SELECT 3::SMALLINT, 960, 1140, TRUE, FALSE
    UNION ALL SELECT gs::SMALLINT, 1140, 1140, TRUE, FALSE FROM generate_series(4,16) gs
    -- Zone 2-only
    UNION ALL SELECT 1::SMALLINT, 300, 600, FALSE, TRUE
)
INSERT INTO ref.railpay_money (
  zone_count, base_fare_cents, capping_fare_cents, is_zone_1, is_zone_2, status_active
)
SELECT zc, bf, cf, iz1, iz2, 'active'::TEXT
FROM metro_zone_mapping
ON CONFLICT (zone_count, is_zone_1, is_zone_2) DO UPDATE
SET base_fare_cents    = EXCLUDED.base_fare_cents,
    capping_fare_cents = EXCLUDED.capping_fare_cents,
    updated_at         = NOW();

-- Seed: Regional “excluding Zone 1” (full fare only)
WITH regional_zone_mapping AS (
    SELECT 1::SMALLINT AS zc, 300 AS bf, 600 AS cf
    UNION ALL SELECT 2, 400, 800
    UNION ALL SELECT 3, 440, 880 
    UNION ALL SELECT 4, 580, 1140 
    UNION ALL SELECT 5, 660, 1140 
    UNION ALL SELECT 6, 800, 1140 
    UNION ALL SELECT 7, 960, 1140 
    UNION ALL SELECT gs, 1140, 1140 FROM generate_series(8, 16) gs
)
INSERT INTO ref.railpay_money (
  zone_count, base_fare_cents, capping_fare_cents, is_zone_1, is_zone_2, status_active
)
SELECT zc, bf, cf, FALSE, FALSE, 'active'::TEXT 
FROM regional_zone_mapping;