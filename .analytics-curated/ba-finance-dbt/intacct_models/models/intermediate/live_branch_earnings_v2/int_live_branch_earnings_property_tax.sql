with real_property_tax_charge as (
    select *
    from {{ ref('stg_analytics_branch_earnings__real_property_tax_charge') }}
),

live_branch_earnings_months as ({{ live_be_period_firstday_of_each_month() }}),

property_tax as (
    select
        real_property_tax_charge.market_id,
        'HIAC' as account_number,
        'Tax Accrual Market ID' as transaction_number_format,
        real_property_tax_charge.market_id::varchar as transaction_number,
        'Property Tax Estimate From Previous Month' as description,
        live_branch_earnings_months.datelist as gl_date,
        'Tax Accrual' as document_type,
        real_property_tax_charge.market_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        real_property_tax_charge.monthly_real_property_tax_charge as amount,
        object_construct() as additional_data,
        'ANALYTICS' as source,
        'Tax Accrual' as load_section,
        '{{ this.name }}' as source_model
    from real_property_tax_charge
        inner join live_branch_earnings_months
            on live_branch_earnings_months.datelist
                between real_property_tax_charge.start_date
                and coalesce(real_property_tax_charge.end_date, '2099-12-31 23:59:59.999')
    where real_property_tax_charge.market_id regexp '^[0-9]+$'
)

select * from property_tax
