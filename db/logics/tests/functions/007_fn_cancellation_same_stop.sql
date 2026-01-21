BEGIN;
DO $$
DECLARE
  v_card_id BIGINT;
  v_route_id INT;
  v_station_row_id SMALLINT;
  v_start_zone SMALLINT;
  v_journey_id BIGINT;
  v_started_at TIMESTAMPTZ;
  v_fare_cents INT;
  v_end_zone SMALLINT;
  v_status TEXT;
  v_end_station_id SMALLINT;
BEGIN
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

  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTCANCEL01', 10000, 1)
  RETURNING card_id INTO v_card_id;

  v_started_at := NOW() - INTERVAL '5 minutes';
  INSERT INTO journey.rail_journeys (card_id, rail_route_id, start_station_id, started_at, status)
  VALUES (v_card_id, v_route_id, v_station_row_id, v_started_at, 'open')
  RETURNING journey_id INTO v_journey_id;

  INSERT INTO journey.rail_journey_fares (
    journey_id, journey_started_at, start_zone, fare_cents, fare_reason
  ) VALUES (
    v_journey_id, v_started_at, v_start_zone, 300, 'full_fare'
  );

  PERFORM ref.fn_cancellation_same_stop(v_journey_id, v_station_row_id);

  SELECT fare_cents, end_zone
  INTO v_fare_cents, v_end_zone
  FROM journey.rail_journey_fares
  WHERE journey_id = v_journey_id;

  IF v_fare_cents <> 0 THEN
    RAISE EXCEPTION 'expected fare_cents=0 got %', v_fare_cents;
  END IF;
  IF v_end_zone <> v_start_zone THEN
    RAISE EXCEPTION 'expected end_zone=% got %', v_start_zone, v_end_zone;
  END IF;

  SELECT status, end_station_id
  INTO v_status, v_end_station_id
  FROM journey.rail_journeys
  WHERE journey_id = v_journey_id;

  IF v_status <> 'cancelled' THEN
    RAISE EXCEPTION 'expected status=cancelled got %', v_status;
  END IF;
  IF v_end_station_id <> v_station_row_id THEN
    RAISE EXCEPTION 'expected end_station_id=% got %', v_station_row_id, v_end_station_id;
  END IF;
END $$;
ROLLBACK;
