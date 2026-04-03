with source as (
    select * from {{ source('analytics_public', 'rateachievement_points') }}
)

, renamed as (
    select
    -- ids
    line_item_id,
    rental_id,
    asset_id,
    equipment_class_id,
    invoice_id,
    market_id,
    salesperson_user_id,
    invoiced_equipment_class_id,
    company_id,
    rate_tier,
    grace_rate_tier,

    -- strings
    model,
    category,
    equipment_class,
    salesperson,
    invoiced_equipment_class,
    company_name,

    -- booleans
    daily_billing_flag,
    grace_period_flag,
    is_above_bench,

    -- numerics
    amount,
    oec,
    percent_discount,
    online_rate,
    floor_rate,
    grace_online_rate,
    grace_floor_rate,

    -- timestamp
    billing_approved_date,
    invoice_date_created

    from source

)
select * from renamed
