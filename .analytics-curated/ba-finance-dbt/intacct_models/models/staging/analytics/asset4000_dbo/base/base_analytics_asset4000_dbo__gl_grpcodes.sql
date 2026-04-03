with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_grpcodes') }}

)

, renamed as (

    select

        -- ids
        grp_order as group_order,
        grp_code as group_code,
        grptag_order as group_id,

        -- strings
        ent_name as entity_name,
        grp_name as group_name,
        grp_sdesc as group_short_description,
        grp_barcode  as barcode,

        -- numerics
        -- booleans
        _fivetran_deleted,

        case 
            when grp_live = 'Y' then TRUE
            when grp_live = 'N' then FALSE
        end as is_group_live,

        case 
            when grp_selectable = 'Y' then TRUE
            when grp_selectable = 'N' then FALSE
        end as is_group_selectable,

        case 
            when grp_pda_live = 'Y' then TRUE
            when grp_pda_live = 'N' then FALSE
        end as is_pda_live,       

        -- dates
        -- timestamps
        _fivetran_synced
    from source
)

select * from renamed
