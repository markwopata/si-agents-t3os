with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_asset_grps') }}

),

renamed as (

    select
    
        -- ids
        ass_code as asset_code,
        assg_grp3 as market_id,

        -- strings
        assg_grp2 as asset_class,
        assg_grp6 as address,

        -- numerics: for MFP (Manufacturing Floor Plan) accounts, convert blank strings to true nulls
        nullif(assg_grp8, '') as asset_account,
        nullif(assg_grp9, '') as accumulated_depreciation_account,
        nullif(assg_grp10, '') as depreciation_expense_account,

        -- booleans
        _fivetran_deleted,

        -- timestamps
        assg_date as asset_gl_assignment_date,
        lead(assg_date) over(partition by asset_code order by assg_date asc) as next_gl_assignment_date,
        _fivetran_synced

    from source

)

select * from renamed
