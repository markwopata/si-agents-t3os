with source as (

select * from {{ source('analytics_market_data', 'scd_market_region') }}

)

, renamed as (
    select
        pkey as pk
        , market_id
        , market_name
        , market_type_id
        , market_type
        , state
        , abbreviation
        , area_code
        , _id_dist
        , district
        , region_district
        , region
        , region_name
        , date_start
        , date_end
        , date_added
        , is_dealership
        , current_flag
        
from source
)

select * from renamed