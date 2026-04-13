#!/bin/bash
# Migration 002: Standardise data_source values
# Run on each ClickHouse host. Pass credentials as arguments:
#   ./run_002_migration.sh localhost default 'v3r8^t1m77'
#   ./run_002_migration.sh 192.168.43.11 default 'password_here'

HOST="${1:-localhost}"
USER="${2:-default}"
PASS="${3}"

if [ -z "$PASS" ]; then
  echo "Usage: $0 <host> <user> <password>"
  exit 1
fi

CH="curl -s http://${HOST}:8123/?user=${USER}&password=${PASS}"

run_mutation() {
  local desc="$1"
  local query="$2"
  echo -n "[$desc] Running... "
  $CH -d "$query"
  while [ "$($CH -d 'SELECT count() FROM system.mutations WHERE is_done = 0')" != "0" ]; do
    sleep 2
  done
  echo "done."
}

run_mutation "GOVT_AQ/GOVT_AQ_NZ → per-council" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = network_source, data_source_name = CASE network_source WHEN 'ecan' THEN 'Environment Canterbury' WHEN 'tasman' THEN 'Tasman District Council' WHEN 'nelson' THEN 'Nelson City Council' WHEN 'marlborough' THEN 'Marlborough District Council' WHEN 'hawkesbay' THEN 'Hawke''s Bay Regional Council' WHEN 'gisborne' THEN 'Gisborne District Council' WHEN 'horizons' THEN 'Horizons Regional Council' WHEN 'westcoast' THEN 'West Coast Regional Council' ELSE network_source END, network_source = 'api', board_model = '', sensor_model = '', calibration_status = CASE WHEN network_source = 'ecan' THEN 'calibrated' ELSE '' END, transport_type = '' WHERE data_source IN ('GOVT_AQ_NZ', 'GOVT_AQ')"

run_mutation "hawkesbay → hawkes_bay" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'hawkes_bay', data_source_name = 'Hawke''s Bay Regional Council' WHERE data_source = 'hawkesbay'"

run_mutation "hawkesbay device_id rename" \
  "ALTER TABLE wesense.sensor_readings UPDATE device_id = replaceOne(device_id, 'govaq_nz_hawkesbay_', 'govaq_nz_hawkes_bay_') WHERE device_id LIKE 'govaq_nz_hawkesbay_%'"

run_mutation "MESHTASTIC_* → meshtastic" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'meshtastic', data_source_name = 'Meshtastic', network_source = 'mqtt', transport_type = 'lora', calibration_status = '' WHERE data_source IN ('MESHTASTIC_COMMUNITY', 'MESHTASTIC_DOWNLINK', 'MESHTASTIC', 'MESHTASTIC_PUBLIC')"

run_mutation "WESENSE → wesense" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'wesense', data_source_name = 'WeSense', network_source = 'mqtt', transport_type = 'wifi' WHERE data_source = 'WESENSE'"

run_mutation "TTN → wesense" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'wesense', data_source_name = 'WeSense', network_source = 'ttn', transport_type = 'lorawan' WHERE data_source = 'TTN'"

run_mutation "CHIRPSTACK → wesense" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'wesense', data_source_name = 'WeSense', network_source = 'chirpstack', transport_type = 'lorawan' WHERE data_source = 'CHIRPSTACK'"

run_mutation "HOMEASSISTANT → home_assistant" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'home_assistant', data_source_name = 'Home Assistant', network_source = 'api', calibration_status = '', transport_type = '' WHERE data_source = 'HOMEASSISTANT'"

run_mutation "HA_PLUGIN → home_assistant" \
  "ALTER TABLE wesense.sensor_readings UPDATE data_source = 'home_assistant', data_source_name = 'Home Assistant', network_source = 'plugin', calibration_status = '', transport_type = '' WHERE data_source = 'HA_PLUGIN'"

run_mutation "calibration_status unknown → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE calibration_status = '' WHERE calibration_status = 'unknown'"

run_mutation "transport_type unknown → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE transport_type = '' WHERE transport_type = 'unknown'"

run_mutation "deployment_type unknown → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE deployment_type = '' WHERE deployment_type = 'unknown'"

run_mutation "location_source unknown → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE location_source = '' WHERE location_source = 'unknown'"

run_mutation "deployment_type_source unknown → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE deployment_type_source = '' WHERE deployment_type_source = 'unknown'"

run_mutation "GOVT_REFERENCE → blank" \
  "ALTER TABLE wesense.sensor_readings UPDATE board_model = '' WHERE board_model = 'GOVT_REFERENCE'"

echo ""
echo "=== Verification ==="
echo "Pending mutations:"
$CH -d "SELECT count() FROM system.mutations WHERE is_done = 0"
echo "Old uppercase data_source values remaining (should be empty):"
$CH -d "SELECT DISTINCT data_source FROM wesense.sensor_readings WHERE data_source = upper(data_source) AND data_source != '' ORDER BY data_source"
echo "Current data_source values:"
$CH -d "SELECT data_source, data_source_name, count() as cnt FROM wesense.sensor_readings GROUP BY data_source, data_source_name ORDER BY cnt DESC"
echo ""
echo "Migration complete."
