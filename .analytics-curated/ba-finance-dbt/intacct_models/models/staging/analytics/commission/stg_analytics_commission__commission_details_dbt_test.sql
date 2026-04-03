with source as (
    select * from {{ source('analytics_commission', 'commission_details_dbt_test') }}
),

renamed as (
    select
        -- ids
        commission_id,
        line_item_id,
        salesperson_user_id,
        invoice_id,
        order_id,
        market_id,
        parent_market_id,
        company_id,
        line_item_type_id,
        invoice_class_id,
        rental_class_id,
        employee_id,
        commission_type_id,
        employee_manager_id,
        salesperson_type_id,
        rate_tier_id,
        business_segment_id,
        rental_id,
        transaction_type_id,
        credit_note_line_item_id,

        -- strings
        invoice_no,
        market_name,
        parent_market_name,
        region,
        region_name,
        district,
        ship_to_state,
        company_name,
        line_item_type,
        invoice_asset_make,
        invoice_class,
        rental_class,
        email_address,
        full_name,
        employee_title,
        employee_manager,
        salesperson_type,
        rate_tier_name,
        cheapest_period,
        quoted_rates,
        transaction_type,
        transaction_description,
        credit_transaction_type,

        -- numerics
        line_item_amount,
        amount,
        secondary_rep_count,
        book_rate,
        benchmark_rate,
        floor_rate,
        billing_days,
        employee_override_rate,
        company_override_rate,
        line_item_override_rate,
        commission_rate,
        split,
        reimbursement_factor,
        commission_amount,

        -- booleans
        is_exception,
        is_override,
        is_commission_eligible,
        hidden,

        -- timestamps
        paid_date,
        order_date,
        rental_date_created,
        rental_start_date,
        transaction_date,
        billing_approved_date,
        commission_month,
        paycheck_date

    from source
)

select * from renamed
