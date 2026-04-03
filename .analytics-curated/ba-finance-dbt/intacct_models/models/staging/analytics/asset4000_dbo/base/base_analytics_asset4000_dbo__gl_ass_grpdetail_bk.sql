with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_ass_grpdetail_bk') }}

),

renamed as (

    select

        -- ids
        grptag_order as group_id,
        grp_code as group_code,
        book_code,
        nullif(assgdbk_depcode, '') as depreciation_code,

        -- strings
        assgdbk_change_type as change_type,
        ent_name as entity_name,
        assgdbk_distype as disposal_type,
        nullif(assgdbk_acqtype, '') as acquisition_type,

        -- numerics
        assgdbk_life as useful_life_years,
        assgdbk_insureprct as insure_percent_points,
        assgdbk_insureprct / 100 as insure_percentage,
        assgdbk_capvalue as capitalization_value,
        assgdbk_disprct as disposal_percent_points,
        assgdbk_disprct / 100 as disposal_percentage,
        assgdbk_residprct as residual_percent_points,
        assgdbk_residprct / 100 as residual_percentage,
        assgdbk_acqprct as acquisition_percent_points,
        assgdbk_acqprct / 100 as acquisition_percentage,

        -- booleans
        assgdbk_irs_electads,
        _fivetran_deleted,

        -- timestamps
        assgdbk_residpct_mod_on as residual_percent_last_modified_timestamp,

        -- dates
        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
