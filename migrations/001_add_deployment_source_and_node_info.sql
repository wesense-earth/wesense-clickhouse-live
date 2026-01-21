-- Migration: Add deployment_type_source, node_info, and node_info_url columns
-- Run this on existing databases to add the new columns

-- Add deployment_type_source to track manual vs inferred classification
ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS deployment_type_source LowCardinality(String) DEFAULT 'unknown';

-- Add node_info for physical setup descriptions (e.g., "outdoor pole, perspex case")
ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS node_info Nullable(String);

-- Add node_info_url for links to detailed documentation/wiki pages
ALTER TABLE wesense.sensor_readings
    ADD COLUMN IF NOT EXISTS node_info_url Nullable(String);
