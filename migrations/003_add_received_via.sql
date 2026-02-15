-- Migration 003: Add received_via column for local vs P2P provenance tracking
-- This column is operational metadata (not archived to IPFS).
-- Run against live ClickHouse:
--   clickhouse-client --host 192.168.43.11 --user wesense --password <pw> --multiquery < 003_add_received_via.sql

ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS received_via LowCardinality(String) DEFAULT 'local';
