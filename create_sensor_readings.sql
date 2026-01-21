-- WeSense sensor_readings table
-- Primary table for all sensor data ingestion

CREATE TABLE IF NOT EXISTS wesense.sensor_readings
(
    `timestamp` DateTime64(3, 'UTC'),
    `device_id` String,
    `data_source` LowCardinality(String),
    `network_source` LowCardinality(String),
    `ingestion_node_id` LowCardinality(String) DEFAULT '',
    `reading_type` LowCardinality(String),
    `value` Float64,
    `unit` LowCardinality(String) DEFAULT '',
    `sample_count` UInt16 DEFAULT 1,
    `sample_interval_avg` UInt16 DEFAULT 300,
    `value_min` Float64 DEFAULT 0,
    `value_max` Float64 DEFAULT 0,
    `latitude` Float64,
    `longitude` Float64,
    `altitude` Nullable(Float32),
    `geo_country` LowCardinality(String),
    `geo_subdivision` LowCardinality(String) DEFAULT '',
    `geo_h3_res8` UInt64 DEFAULT 0,
    `sensor_model` LowCardinality(String) DEFAULT '',
    `board_model` LowCardinality(String) DEFAULT '',
    `calibration_status` LowCardinality(String) DEFAULT 'unknown',
    `data_quality_flag` LowCardinality(String) DEFAULT 'unvalidated',
    `deployment_type` LowCardinality(String) DEFAULT 'unknown',
    `transport_type` LowCardinality(String) DEFAULT 'unknown',
    `location_source` LowCardinality(String) DEFAULT 'unknown',
    `firmware_version` Nullable(String),
    `deployment_location` Nullable(String),
    `node_name` Nullable(String),
    `deployment_type_source` LowCardinality(String) DEFAULT 'unknown',
    `node_info` Nullable(String),
    `node_info_url` Nullable(String)
)
ENGINE = ReplacingMergeTree(timestamp)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (device_id, reading_type, timestamp)
TTL timestamp + toIntervalDay(90)
SETTINGS index_granularity = 8192;
