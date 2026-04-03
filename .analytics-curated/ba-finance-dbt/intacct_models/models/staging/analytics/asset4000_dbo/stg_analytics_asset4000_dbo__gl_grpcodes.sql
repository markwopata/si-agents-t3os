with base as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_grpcodes') }}

)

, renamed as (

    select

        -- ids
        group_order,
        group_code,
        group_id,

        -- strings
        entity_name,
        group_name,
        group_short_description,
        barcode,

        -- numerics
        -- booleans
        _fivetran_deleted,

        is_group_live,
        is_group_selectable,
        is_pda_live,       

        -- dates
        -- timestamps
        _fivetran_synced

    from base
    where _fivetran_deleted != TRUE
)

select * from renamed
