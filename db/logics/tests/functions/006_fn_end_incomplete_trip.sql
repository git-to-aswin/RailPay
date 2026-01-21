BEGIN;
DO $$
DECLARE
  v_card_id BIGINT;
  v_card_balance INT := 10000;
  v_route_id INT;
  v_station_row_id SMALLINT;
  v_start_zone SMALLINT;
  v_journey_id BIGINT;
  v_started_at TIMESTAMPTZ;
  v_base_fare_cents INT;
  v_capping_fare_cents INT;
  v_fare_cents INT;
  v_balance_after INT;
BEGIN
  -- Pick a station on a route
  SELECT rrs.route_id, rrs.station_id
  INTO v_route_id, v_station_row_id
  FROM ref.rail_route_stations rrs
  ORDER BY rrs.route_id, rrs.stop_sequence
  LIMIT 1;

  IF v_route_id IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: no routes available';
  END IF;

  SELECT zone_id
  INTO v_start_zone
  FROM ref.stations
  WHERE id = v_station_row_id;

  IF v_start_zone IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: station zone not found';
  END IF;

  SELECT base_fare_cents, capping_fare_cents
  INTO v_base_fare_cents, v_capping_fare_cents
  FROM ref.railpay_money
  WHERE zone_count = 1
    AND is_zone_1 = (v_start_zone = 1)
    AND is_zone_2 = (v_start_zone = 2)
    AND status_active = 'active'
  LIMIT 1;

  IF v_base_fare_cents IS NULL OR v_capping_fare_cents IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: fare config missing for start_zone=%', v_start_zone;
  END IF;

  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTINC0001', v_card_balance, 1)
  RETURNING card_id INTO v_card_id;

  -- Case 1: normal incomplete trip charges base fare
  v_started_at := NOW() - INTERVAL '5 minutes';
  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (v_card_id, v_route_id, v_station_row_id, v_started_at, 'open')
  RETURNING journey_id INTO v_journey_id;

  INSERT INTO journey.rail_journey_fares (
    journey_id, journey_started_at, start_zone, fare_cents, fare_reason
  ) VALUES (
    v_journey_id, v_started_at, v_start_zone, 0, 'full_fare'
  );

  PERFORM ref.fn_end_incomplete_trip(v_card_id, v_journey_id, v_start_zone);

  SELECT fare_cents
  INTO v_fare_cents
  FROM journey.rail_journey_fares
  WHERE journey_id = v_journey_id;

  IF v_fare_cents <> v_base_fare_cents THEN
    RAISE EXCEPTION 'expected fare_cents=% got %', v_base_fare_cents, v_fare_cents;
  END IF;

  SELECT balance_cents
  INTO v_balance_after
  FROM card.rail_cards
  WHERE card_id = v_card_id;

  IF v_balance_after <> v_card_balance - v_base_fare_cents THEN
    RAISE EXCEPTION 'expected balance=% got %', v_card_balance - v_base_fare_cents, v_balance_after;
  END IF;

  -- Case 2: already capped, fare should be zero
  v_started_at := NOW() - INTERVAL '2 minutes';
  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (v_card_id, v_route_id, v_station_row_id, v_started_at - INTERVAL '1 hour', 'closed')
  RETURNING journey_id INTO v_journey_id;

  INSERT INTO journey.rail_journey_fares (
    journey_id, journey_started_at, start_zone, fare_cents, fare_reason
  ) VALUES (
    v_journey_id, v_started_at - INTERVAL '1 hour', v_start_zone, v_capping_fare_cents, 'full_fare'
  );

  v_started_at := NOW() - INTERVAL '1 minute';
  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (v_card_id, v_route_id, v_station_row_id, v_started_at, 'open')
  RETURNING journey_id INTO v_journey_id;

  INSERT INTO journey.rail_journey_fares (
    journey_id, journey_started_at, start_zone, fare_cents, fare_reason
  ) VALUES (
    v_journey_id, v_started_at, v_start_zone, 0, 'full_fare'
  );

  PERFORM ref.fn_end_incomplete_trip(v_card_id, v_journey_id, v_start_zone);

  SELECT fare_cents
  INTO v_fare_cents
  FROM journey.rail_journey_fares
  WHERE journey_id = v_journey_id;

  IF v_fare_cents <> 0 THEN
    RAISE EXCEPTION 'expected capped fare_cents=0 got %', v_fare_cents;
  END IF;
END $$;
ROLLBACK;
