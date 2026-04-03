with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_grpcde_crossref') }}

),

renamed as (

    select

        -- ids
        cref_tag_order as cross_reference_tag_order,
        grp_code as group_code,

        -- strings
        ent_name as entity_name,
        cref_entity as cross_reference_entity,
        cref_grpcode as cross_reference_group_code,

        -- numerics
        grptag_order as group_tag_order,

        -- booleans
        _fivetran_deleted,

        -- dates
        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
