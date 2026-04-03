with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_grp_tags') }}

),

renamed as (

    select

        -- ids
        ent_name as entity_name,
        grptag_order as group_id,


        -- strings
        grptag_mandatory,
        grptag_exemptgrp,
        grptag_option2,
        grptag_name as group_tag_name,
        grptag_restrict,
        grptag_option1,
        grptag_accessgrp,
        grptag_restrict_group,
        grptag_security,

        -- numerics
        -- booleans
        _fivetran_deleted,

        -- dates
        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
