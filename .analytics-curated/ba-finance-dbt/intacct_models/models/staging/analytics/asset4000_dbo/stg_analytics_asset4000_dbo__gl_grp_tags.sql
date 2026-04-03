with base as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_grp_tags') }}

)

, renamed as (

    select

        -- ids
        entity_name,
        group_id,

        -- strings
        grptag_mandatory,
        grptag_exemptgrp,
        grptag_option2,
        group_tag_name,
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

    from base
    where _fivetran_deleted != TRUE
)

select * from renamed
