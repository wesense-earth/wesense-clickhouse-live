CREATE MATERIALIZED VIEW wesense.sensors_daily_mv TO wesense.sensors_daily AS
SELECT
    toDate(timestamp) AS date,
    'daily' AS aggregation_level,

    geo_country,
    reading_type,

    -- Aggregation functions
    avg(value) AS value_mean,
    min(value) AS value_min,
    max(value) AS value_max,
    stddevPop(value) AS value_stddev,
    quantile(0.5)(value) AS value_p50,
    quantile(0.95)(value) AS value_p95,

    uniq(device_id) AS device_count,
    count() AS reading_count,

    CAST(NULL AS Nullable(String)) AS ipfs_cid,
    false AS exported_to_ipfs

FROM wesense.sensors_raw
WHERE data_quality_flag = 'valid' -- Important: only aggregate valid data
GROUP BY
    date,
    geo_country,
    reading_type;
