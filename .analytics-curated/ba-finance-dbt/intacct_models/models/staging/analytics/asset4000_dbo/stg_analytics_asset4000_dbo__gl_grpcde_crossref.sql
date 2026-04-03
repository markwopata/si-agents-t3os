with base as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_grpcde_crossref') }}

)

, renamed as (

    select

        -- ids
        cross_reference_tag_order,
        group_code,

        -- strings
        entity_name,
        cross_reference_entity,
        cross_reference_group_code,

        -- numerics
        group_tag_order,
        
        -- booleans
        _fivetran_deleted,
    
        -- dates
        -- timestamps
        _fivetran_synced

    from base
    where _fivetran_deleted != TRUE
)

select * from renamed
