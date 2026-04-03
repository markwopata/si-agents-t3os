with source as (

    select * from {{ source('analytics_branch_earnings', 'real_property_tax_charge') }}

),

renamed as (

    select

        -- id
        market_id::int as market_id,

        -- strings
        market_name,

        -- dates
        start_date,
        end_date,

        -- numerics
        yearly_rpt_charge as yearly_real_property_tax_charge,
        monthly_rpt_charge as monthly_real_property_tax_charge

    from source

)

select * from renamed
