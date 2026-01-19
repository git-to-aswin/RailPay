-- Make sure schema exists (safe if already created)
CREATE SCHEMA IF NOT EXISTS card;

-- Enable btree_gist extension for advanced indexing
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 1) cards
CREATE TABLE IF NOT EXISTS card.rail_cards (
    card_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    card_number VARCHAR(16) NOT NULL UNIQUE,
    balance_cents INT NOT NULL CHECK (balance_cents >= 0),
    card_type_id SMALLINT NOT NULL REFERENCES ref.railpay_card_types(card_type_id),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railcard__card_id ON card.rail_cards(card_id);
CREATE INDEX IF NOT EXISTS idx_railcard__card_number ON card.rail_cards(card_number);

-- 2) travel_passes
CREATE TABLE IF NOT EXISTS card.rail_passes (
  pass_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  card_id BIGINT NOT NULL REFERENCES card.rail_cards(card_id),

  purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  purchasing_interval INTERVAL NOT NULL
    CHECK (purchasing_interval > INTERVAL '0 seconds'),

  bonus_days SMALLINT NOT NULL DEFAULT 0
    CHECK (bonus_days >= 0 AND bonus_days <= 40),

  valid_from TIMESTAMPTZ NOT NULL,

  -- computed by trigger
  valid_to TIMESTAMPTZ NOT NULL,
  valid_range tstzrange NOT NULL,

  price_cents INT NOT NULL CHECK (price_cents >= 0),

  status_active TEXT NOT NULL DEFAULT 'active'
    CHECK (status_active IN ('active', 'expired', 'refunded', 'failed', 'paused', 'cancelled')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT rail_passes_validity_chk CHECK (valid_to > valid_from)
);

-- Trigger to auto-compute valid_to and valid_range
CREATE OR REPLACE FUNCTION card.set_rail_pass_validity()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.valid_to :=
    NEW.valid_from
    + NEW.purchasing_interval
    + make_interval(days => NEW.bonus_days);

  NEW.valid_range := tstzrange(NEW.valid_from, NEW.valid_to, '[)');

  NEW.updated_at := NOW();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_set_rail_pass_validity ON card.rail_passes;

CREATE TRIGGER trg_set_rail_pass_validity
BEFORE INSERT OR UPDATE OF valid_from, purchasing_interval, bonus_days
ON card.rail_passes
FOR EACH ROW
EXECUTE FUNCTION card.set_rail_pass_validity();

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railpasses__active_card_validrange ON card.rail_passes USING gist (card_id, tstzrange(valid_from, valid_to, '[)')) WHERE status_active = 'active';

-- 3) travel_zone_passes
CREATE TABLE IF NOT EXISTS card.railpass_zones (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    pass_id BIGINT NOT NULL REFERENCES card.rail_passes(pass_id),
    zone_id SMALLINT NOT NULL REFERENCES ref.travel_zones(zone_id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT railpass_zones_pass_zone_uk UNIQUE (pass_id, zone_id)
);