-- Migration: Standardise data_source, network_source, and metadata values
-- Run on both .11 and .13 ClickHouse instances
-- Safe to run multiple times (idempotent)
-- Run each statement sequentially — monitor with:
--   SELECT * FROM system.mutations WHERE is_done = 0

-- ═══════════════════════════════════════════════════════════════════
-- 1. GOVT_AQ_NZ → split by network_source into per-council data_source
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = network_source,
    data_source_name = CASE network_source
        WHEN 'ecan' THEN 'Environment Canterbury'
        WHEN 'tasman' THEN 'Tasman District Council'
        WHEN 'nelson' THEN 'Nelson City Council'
        WHEN 'marlborough' THEN 'Marlborough District Council'
        WHEN 'hawkesbay' THEN 'Hawke''s Bay Regional Council'
        WHEN 'gisborne' THEN 'Gisborne District Council'
        WHEN 'horizons' THEN 'Horizons Regional Council'
        WHEN 'westcoast' THEN 'West Coast Regional Council'
        ELSE network_source
    END,
    network_source = 'api',
    board_model = '',
    sensor_model = '',
    calibration_status = CASE WHEN network_source = 'ecan' THEN 'calibrated' ELSE '' END,
    transport_type = ''
WHERE data_source = 'GOVT_AQ_NZ';

-- 1b. Same for old GOVT_AQ data
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = network_source,
    data_source_name = CASE network_source
        WHEN 'ecan' THEN 'Environment Canterbury'
        WHEN 'tasman' THEN 'Tasman District Council'
        WHEN 'nelson' THEN 'Nelson City Council'
        WHEN 'marlborough' THEN 'Marlborough District Council'
        WHEN 'hawkesbay' THEN 'Hawke''s Bay Regional Council'
        WHEN 'gisborne' THEN 'Gisborne District Council'
        WHEN 'horizons' THEN 'Horizons Regional Council'
        WHEN 'westcoast' THEN 'West Coast Regional Council'
        ELSE network_source
    END,
    network_source = 'api',
    board_model = '',
    sensor_model = '',
    calibration_status = CASE WHEN network_source = 'ecan' THEN 'calibrated' ELSE '' END,
    transport_type = ''
WHERE data_source = 'GOVT_AQ';

-- ═══════════════════════════════════════════════════════════════════
-- 2. hawkesbay → hawkes_bay (data_source and device_id)
--    Run AFTER mutations 1/1b complete
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'hawkes_bay',
    data_source_name = 'Hawke''s Bay Regional Council'
WHERE data_source = 'hawkesbay';

ALTER TABLE wesense.sensor_readings UPDATE
    device_id = replaceOne(device_id, 'govaq_nz_hawkesbay_', 'govaq_nz_hawkes_bay_')
WHERE device_id LIKE 'govaq_nz_hawkesbay_%';

-- ═══════════════════════════════════════════════════════════════════
-- 3. MESHTASTIC_* → meshtastic
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'meshtastic',
    data_source_name = 'Meshtastic',
    network_source = 'mqtt',
    transport_type = 'lora',
    calibration_status = ''
WHERE data_source IN ('MESHTASTIC_COMMUNITY', 'MESHTASTIC_DOWNLINK', 'MESHTASTIC', 'MESHTASTIC_PUBLIC');

-- ═══════════════════════════════════════════════════════════════════
-- 4. WESENSE → wesense (leave calibration_status as-is — device-reported)
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'wesense',
    data_source_name = 'WeSense',
    network_source = 'mqtt',
    transport_type = 'wifi'
WHERE data_source = 'WESENSE';

-- ═══════════════════════════════════════════════════════════════════
-- 5. TTN → wesense (leave calibration_status as-is)
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'wesense',
    data_source_name = 'WeSense',
    network_source = 'ttn',
    transport_type = 'lorawan'
WHERE data_source = 'TTN';

-- ═══════════════════════════════════════════════════════════════════
-- 6. CHIRPSTACK → wesense (leave calibration_status as-is)
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'wesense',
    data_source_name = 'WeSense',
    network_source = 'chirpstack',
    transport_type = 'lorawan'
WHERE data_source = 'CHIRPSTACK';

-- ═══════════════════════════════════════════════════════════════════
-- 7. HOMEASSISTANT → home_assistant
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'home_assistant',
    data_source_name = 'Home Assistant',
    network_source = 'api',
    calibration_status = '',
    transport_type = ''
WHERE data_source = 'HOMEASSISTANT';

-- ═══════════════════════════════════════════════════════════════════
-- 8. HA_PLUGIN → home_assistant
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    data_source = 'home_assistant',
    data_source_name = 'Home Assistant',
    network_source = 'plugin',
    calibration_status = '',
    transport_type = ''
WHERE data_source = 'HA_PLUGIN';

-- ═══════════════════════════════════════════════════════════════════
-- 9. Clean up legacy 'unknown' values
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    calibration_status = ''
WHERE calibration_status = 'unknown';

ALTER TABLE wesense.sensor_readings UPDATE
    transport_type = ''
WHERE transport_type = 'unknown';

ALTER TABLE wesense.sensor_readings UPDATE
    deployment_type = ''
WHERE deployment_type = 'unknown';

ALTER TABLE wesense.sensor_readings UPDATE
    location_source = ''
WHERE location_source = 'unknown';

ALTER TABLE wesense.sensor_readings UPDATE
    deployment_type_source = ''
WHERE deployment_type_source = 'unknown';

-- ═══════════════════════════════════════════════════════════════════
-- 10. Clean up hardcoded GOVT_REFERENCE board_model
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE wesense.sensor_readings UPDATE
    board_model = ''
WHERE board_model = 'GOVT_REFERENCE';
