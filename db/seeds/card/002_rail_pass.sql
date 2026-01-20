INSERT INTO card.rail_passes (card_id, purchasing_interval, valid_from, price_cents)
VALUES
(2, INTERVAL '326 days', NOW(), 5000),
(3, INTERVAL '5 days', NOW() + INTERVAL '1 day', 1500),
(4, INTERVAL '26 days', NOW() - INTERVAL '10 days', 12000);