 -- depends_on: {{ ref('fact_safety_observation_details') }}
 
{{ config(
    materialized='incremental',
    unique_key=['safety_observation_photo_key'],
    incremental_strategy='delete+insert'
) }}

WITH safety_observation_with_photos as (
    SELECT 
        safety_observation_id
        , photos
    FROM {{ ref('stg_jotform__safety_observation') }} 
    WHERE COALESCE(ARRAY_SIZE(photos), 0) > 0
    AND {{ filter_source_updates('submission_datetime', buffer_amount=1, time_unit='day') }}
)

    , flatten_photos AS (
        select 
            t.safety_observation_id
            , t.photos
            , f.value::string as photo
        FROM safety_observation_with_photos t,
        lateral flatten(input => t.photos) f
    )

select
    {{ dbt_utils.generate_surrogate_key([
        'safety_observation_id', 'photo']) 
    }} AS safety_observation_photo_key
    , {{ dbt_utils.generate_surrogate_key([
        'safety_observation_id']) 
    }} AS safety_observation_key
    , photo

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from flatten_photos