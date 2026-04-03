{{ config(
    materialized='incremental'
    , unique_key=['asset_id']
    , incremental_strategy='merge'
    , merge_exclude_columns = ['_created_recordtimestamp']
) }}

-- Location comes in WKT/GeoJSON/EWKT format
select asset_id
    , geofences
    , address
    , location -- location is now coordinates vs EWKT format 
    , null as last_location_geo -- TRY_TO_GEOGRAPHY(location)
    , null as latitude -- ST_Y(last_location_geo)
    , null as longitude -- ST_X(last_location_geo)
    , CAST(last_location_timestamp AS TIMESTAMP_NTZ)  AS last_location_timestamp
    , CAST(last_checkin_timestamp  AS TIMESTAMP_NTZ)  AS last_checkin_timestamp

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from {{ ref('platform', 'es_warehouse__public__asset_last_location') }} 

{% if is_incremental() -%}
WHERE ({{ filter_incremental_with_buffer_day('last_location_timestamp', buffer_days=1) }})
OR ({{ filter_incremental_with_buffer_day('last_checkin_timestamp', buffer_days=1) }})
{%- endif -%}