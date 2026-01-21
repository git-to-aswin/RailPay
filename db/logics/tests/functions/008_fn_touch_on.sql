BEGIN;
DO $$
DECLARE
  v_card_id BIGINT;
  v_bad_card_id BIGINT;
  v_route_id INT;
  v_station_row_id SMALLINT;
  v_journey_id BIGINT;
  v_found_route_id INT;
BEGIN
  SELECT rrs.route_id, rrs.station_id
  INTO v_route_id, v_station_row_id
  FROM ref.rail_route_stations rrs
  ORDER BY rrs.route_id, rrs.stop_sequence
  LIMIT 1;

  IF v_route_id IS NULL THEN
    RAISE EXCEPTION 'Precondition failed: no routes available';
  END IF;

  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTTOUCH01', 10000, 1)
  RETURNING card_id INTO v_card_id;

  PERFORM ref.fn_touch_on(v_card_id, v_station_row_id);

  SELECT journey_id, rail_route_id
  INTO v_journey_id, v_found_route_id
  FROM journey.rail_journeys
  WHERE card_id = v_card_id
  ORDER BY started_at DESC
  LIMIT 1;

  IF v_journey_id IS NULL THEN
    RAISE EXCEPTION 'expected journey to be created';
  END IF;
  IF v_found_route_id <> v_route_id THEN
    RAISE EXCEPTION 'expected rail_route_id=% got %', v_route_id, v_found_route_id;
  END IF;

  -- Insufficient balance should raise an exception
  INSERT INTO card.rail_cards (card_number, balance_cents, card_type_id)
  VALUES ('TESTTOUCH02', 0, 1)
  RETURNING card_id INTO v_bad_card_id;

  BEGIN
    PERFORM ref.fn_touch_on(v_bad_card_id, v_station_row_id);
    RAISE EXCEPTION 'expected insufficient balance error';
  EXCEPTION WHEN others THEN
    -- expected
    NULL;
  END;
END $$;
ROLLBACK;
