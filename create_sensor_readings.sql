-- WeSense sensor_readings table
-- Primary table for all sensor data ingestion

CREATE TABLE IF NOT EXISTS wesense.sensor_readings
(
    `timestamp` DateTime64(3, 'UTC'),
    `device_id` String,
    `data_source` LowCardinality(String),
    `data_source_name` LowCardinality(String) DEFAULT '',
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
    `calibration_status` LowCardinality(String) DEFAULT '',
    `data_quality_flag` LowCardinality(String) DEFAULT 'unvalidated',
    `deployment_type` LowCardinality(String) DEFAULT '',
    `transport_type` LowCardinality(String) DEFAULT '',
    `location_source` LowCardinality(String) DEFAULT '',
    `firmware_version` Nullable(String),
    `deployment_location` Nullable(String),
    `node_name` Nullable(String),
    `deployment_type_source` LowCardinality(String) DEFAULT '',
    `node_info` Nullable(String),
    `node_info_url` Nullable(String),
    `signature` String DEFAULT '' COMMENT 'Ed25519 signature (hex)',
    `ingester_id` LowCardinality(String) DEFAULT '' COMMENT 'Signing ingester ID (wsi_xxxxxxxx)',
    `key_version` UInt32 DEFAULT 0 COMMENT 'Signing key version',
    `received_via` LowCardinality(String) DEFAULT 'local' COMMENT 'How this station received the reading: local or p2p'
)
ENGINE = ReplacingMergeTree(timestamp)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (device_id, reading_type, timestamp)
TTL toDateTime(timestamp) + toIntervalYear(3)
SETTINGS index_granularity = 8192;
