with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_asset_bk') }}

),

renamed as (

    select
        -- ids
        ass_code as asset_code,

        -- strings
        book_code,
        assbk_irs_depconv as irs_depreciation_convention,
        assbk_acq_type as asset_acquisition_type,

        -- numerics
        assbk_pch_val as asset_purchase_cost,
        assbk_acq_pcnt as depreciation_acquisition_percentage,
        assbk_min_val as asset_minimum_value,
        assbk_res_val as asset_residual_value,
        assbk_irs_sept10depn as irs_bonus_depreciation_amount,

        -- booleans
        case
            when assbk_auc = 'Y' then TRUE
            when assbk_auc = 'N' then FALSE
        end as is_asset_auctioned,
        
        _fivetran_deleted,

        -- dates
        assbk_exp_date as asset_expiration_date,
        assbk_depstart_date as asset_depreciation_start_date,

        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
