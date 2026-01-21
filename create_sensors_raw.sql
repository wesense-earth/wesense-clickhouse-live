-- WeSense ClickHouse Live: sensor_readings table
-- This is the primary table for live sensor data (90-day retention)

CREATE TABLE IF NOT EXISTS wesense.sensor_readings (
    -- Timestamp (partition key)
    timestamp DateTime64(3, 'UTC'),

    -- Identity & Provenance
    device_id String,
    data_source LowCardinality(String),              -- MESHTASTIC, WESENSE, etc.
    network_source LowCardinality(String),           -- msh/ANZ/2/json, wesense/v2, etc.
    ingestion_node_id LowCardinality(String) DEFAULT '',  -- hostname of ingester

    -- Measurement
    reading_type LowCardinality(String),             -- temperature, humidity, pressure, etc.
    value Float64,
    unit LowCardinality(String) DEFAULT '',          -- °C, %, hPa, etc.

    -- Hub Normalization Metadata (for future use)
    sample_count UInt16 DEFAULT 1,                   -- Number of readings averaged by hub
    sample_interval_avg UInt16 DEFAULT 300,          -- Average interval between samples (seconds)
    value_min Float64 DEFAULT 0,                     -- Minimum value in normalization window
    value_max Float64 DEFAULT 0,                     -- Maximum value in normalization window

    -- Geographic
    latitude Float64,
    longitude Float64,
    altitude Nullable(Float32),
    geo_country LowCardinality(String),              -- ISO 3166-1 alpha-2 (nz, au, us)
    geo_subdivision LowCardinality(String) DEFAULT '', -- ISO 3166-2 subdivision (auk, qld, ca)
    geo_h3_res8 UInt64 DEFAULT 0,                    -- H3 index for spatial queries (future)

    -- Hardware
    sensor_model LowCardinality(String) DEFAULT '',  -- SHT4X, BME280, etc.
    board_model LowCardinality(String) DEFAULT '',   -- TBEAM, HELTEC_V3, etc.

    -- Quality & Trust
    calibration_status LowCardinality(String) DEFAULT 'unknown',
    data_quality_flag LowCardinality(String) DEFAULT 'unvalidated',

    -- Context
    deployment_type LowCardinality(String) DEFAULT 'unknown',  -- INDOOR, OUTDOOR, MIXED, UNKNOWN
    deployment_type_source LowCardinality(String) DEFAULT 'unknown',  -- manual, inferred, unknown
    transport_type LowCardinality(String) DEFAULT 'unknown',   -- LORA, WIFI_MQTT, LORAWAN
    location_source LowCardinality(String) DEFAULT 'unknown',  -- gps, manual, estimated

    -- Optional Metadata
    firmware_version Nullable(String),
    deployment_location Nullable(String),            -- User-defined location name
    node_name Nullable(String),                      -- Device name from Meshtastic NODEINFO
    node_info Nullable(String),                      -- Physical setup description (e.g., "outdoor pole, perspex case")
    node_info_url Nullable(String)                   -- URL to detailed documentation/wiki page

) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (geo_country, reading_type, device_id, timestamp)
TTL timestamp + INTERVAL 90 DAY DELETE
SETTINGS index_granularity = 8192;
