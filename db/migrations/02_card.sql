-- Make sure schema exists (safe if already created)
CREATE SCHEMA IF NOT EXISTS card;

-- 1) cards
CREATE TABLE IF NOT EXISTS card.railcard (
    card_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    card_number VARCHAR(16) NOT NULL UNIQUE,
    balance_cents INT NOT NULL CHECK (balance_cents >= 0),
    card_type_id SMALLINT NOT NULL REFERENCES ref.railpay_card_types(card_type_id),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_railcard__card_id ON card.railcard(card_id);
CREATE INDEX IF NOT EXISTS idx_railcard__card_number ON card.railcard(card_number);

-- 2) travel_zone_pass
CREATE TABLE IF NOT EXISTS card.travel_zone_pass (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    card_id BIGINT NOT NULL REFERENCES card.railcard(card_id),
    travel_zone_id SMALLINT NOT NULL REFERENCES ref.travel_zone(zone_id),
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT travel_zone_pass_unique_chk UNIQUE (card_id, travel_zone_id, valid_from)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_travel_zone_pass__card_zone_id ON card.travel_zone_pass(card_id, travel_zone_id) WHERE is_active = TRUE;



