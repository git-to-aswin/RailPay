INSERT INTO ref.railpay_card_types
  (card_type_id, card_type_name, description, is_active)
VALUES
  (1, 'Full Fare',
   'Standard railpay for travellers aged 5+ to travel on most trains, trams and buses in the railpay zone.',
   TRUE),
  (2, 'Concession',
   'Concession railpay provides 50% off fares for eligible travellers (different concession types have different benefits).',
   TRUE),
  (3, 'Student',
   'Student concessions/passes may provide discounted travel for eligible full-time students; rules depend on student type.',
   TRUE),
  (4, 'Youth',
   'Young people under 18 can travel for free on Victorian public transport with a Youth railpay (ages 5–17 inclusive).',
   TRUE),
  (5, 'Free travel',
   'For eligible people who can travel for free on public transport via free travel passes (eligibility rules apply).',
   TRUE)
ON CONFLICT (card_type_id) DO UPDATE
SET card_type_name = EXCLUDED.card_type_name,
    description    = EXCLUDED.description,
    is_active       = EXCLUDED.is_active,
    updated_at      = NOW();