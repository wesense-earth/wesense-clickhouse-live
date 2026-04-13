#!/bin/bash
# Migration 001: Add data_source_name column and fix defaults
# Run on each ClickHouse host. Pass credentials as arguments:
#   ./run_001_migration.sh localhost default 'v3r8^t1m77'
#   ./run_001_migration.sh 192.168.43.11 default 'password_here'

HOST="${1:-localhost}"
USER="${2:-default}"
PASS="${3}"

if [ -z "$PASS" ]; then
  echo "Usage: $0 <host> <user> <password>"
  exit 1
fi

CH="curl -s http://${HOST}:8123/?user=${USER}&password=${PASS}"

run() {
  local desc="$1"
  local query="$2"
  echo -n "[$desc] Running... "
  $CH -d "$query"
  echo "done."
}

run "Add data_source_name column" \
  "ALTER TABLE wesense.sensor_readings ADD COLUMN IF NOT EXISTS data_source_name LowCardinality(String) DEFAULT ''"

run "Fix calibration_status default" \
  "ALTER TABLE wesense.sensor_readings MODIFY COLUMN calibration_status LowCardinality(String) DEFAULT ''"

run "Fix transport_type default" \
  "ALTER TABLE wesense.sensor_readings MODIFY COLUMN transport_type LowCardinality(String) DEFAULT ''"

run "Fix deployment_type default" \
  "ALTER TABLE wesense.sensor_readings MODIFY COLUMN deployment_type LowCardinality(String) DEFAULT ''"

run "Fix location_source default" \
  "ALTER TABLE wesense.sensor_readings MODIFY COLUMN location_source LowCardinality(String) DEFAULT ''"

run "Fix deployment_type_source default" \
  "ALTER TABLE wesense.sensor_readings MODIFY COLUMN deployment_type_source LowCardinality(String) DEFAULT ''"

echo ""
echo "Migration 001 complete."
