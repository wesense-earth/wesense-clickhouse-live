CREATE TABLE wesense.sensors_daily (
    date Date,
    aggregation_level LowCardinality(String) DEFAULT 'daily',

    geo_country LowCardinality(String),
    reading_type LowCardinality(String),

    -- Aggregated values
    value_mean Float64,
    value_min Float64,
    value_max Float64,
    value_stddev Float64,
    value_p50 Float64,
    value_p95 Float64,

    -- Metadata
    device_count UInt32,
    reading_count UInt32,

    -- Export tracking
    ipfs_cid Nullable(String),
    exported_to_ipfs Boolean DEFAULT false

) ENGINE = MergeTree()
PARTITION BY toYYYYMM(date)
ORDER BY (geo_country, reading_type, date);
