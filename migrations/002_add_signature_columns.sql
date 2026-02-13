-- Migration 002: Add Ed25519 signature columns for P2P verification
-- Run against live ClickHouse:
--   clickhouse-client --host 192.168.43.11 --user wesense --password <pw> --multiquery < 002_add_signature_columns.sql

ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS signature String DEFAULT '';

ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS ingester_id LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS key_version UInt32 DEFAULT 0;
