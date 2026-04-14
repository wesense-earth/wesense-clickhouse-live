-- Migration 008: Add public_key column

ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS public_key LowCardinality(String) DEFAULT '';
