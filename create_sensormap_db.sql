-- Respiro database for region mapping and caching
-- Used by wesense-respiro for spatial queries

CREATE DATABASE IF NOT EXISTS wesense_respiro;

-- Region boundaries table for point-in-polygon queries
-- Stores administrative boundaries at multiple levels (ADM0-ADM4)
CREATE TABLE IF NOT EXISTS wesense_respiro.region_boundaries
(
    `region_id` String,
    `admin_level` UInt8,
    `name` String,
    `country_code` String,
    `original_id` String,
    `polygon` Array(Array(Tuple(Float64, Float64))),
    `bbox_min_lon` Float64,
    `bbox_max_lon` Float64,
    `bbox_min_lat` Float64,
    `bbox_max_lat` Float64
)
ENGINE = MergeTree
ORDER BY (admin_level, country_code, region_id)
SETTINGS index_granularity = 8192;

-- Cache device locations to regions (updated periodically)
-- Avoids expensive point-in-polygon queries at read time
CREATE TABLE IF NOT EXISTS wesense_respiro.device_region_cache
(
    `device_id` String,
    `latitude` Float64,
    `longitude` Float64,
    `region_adm0_id` String,
    `region_adm1_id` String,
    `region_adm2_id` String,
    `updated_at` DateTime DEFAULT now(),
    `region_adm3_id` String DEFAULT '',
    `region_adm4_id` String DEFAULT ''
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY device_id
SETTINGS index_granularity = 8192;
