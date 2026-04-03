with recent_companies as (
    SELECT
        f.company_id
        , CASE
            WHEN f.first_account_date_ct::DATE >= DATEADD(day, -45, CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_DATE())::DATE)
            THEN TRUE
            ELSE FALSE
        END as is_new_account
    FROM {{ ref('int_credit_app_first_intake_resolved') }} f
)

select 
    c.company_id
    , COALESCE(recent_companies.is_new_account, FALSE) as is_new_account
    , first_order.date_created IS NOT NULL as has_orders
    , CASE 
        WHEN first_order.date_created IS NOT NULL OR first_rental.date_created IS NOT NULL
        THEN 'Converted'
        WHEN recent_companies.is_new_account AND first_order.date_created IS NULL AND first_rental.date_created IS NULL 
        THEN 'Pending'
        ELSE 'Not Converted' 
    END as conversion_status 

from {{ ref('platform', 'dim_companies') }} c 
left join recent_companies
    ON c.company_id = recent_companies.company_id
left join {{ ref('int_company_first_order') }} first_order
    ON c.company_id = first_order.company_id
left join {{ ref('int_company_first_rental') }} first_rental
    ON c.company_id = first_rental.company_id
where c.company_id <> -1