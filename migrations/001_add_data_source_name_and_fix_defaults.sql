-- Migration: Add data_source_name column and change defaults from 'unknown' to ''
-- Run on both .11 and .13 ClickHouse instances
-- Safe to run multiple times (idempotent)

ALTER TABLE wesense.sensor_readings
  ADD COLUMN IF NOT EXISTS `data_source_name` LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
  MODIFY COLUMN `calibration_status` LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
  MODIFY COLUMN `transport_type` LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
  MODIFY COLUMN `deployment_type` LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
  MODIFY COLUMN `location_source` LowCardinality(String) DEFAULT '';

ALTER TABLE wesense.sensor_readings
  MODIFY COLUMN `deployment_type_source` LowCardinality(String) DEFAULT '';
