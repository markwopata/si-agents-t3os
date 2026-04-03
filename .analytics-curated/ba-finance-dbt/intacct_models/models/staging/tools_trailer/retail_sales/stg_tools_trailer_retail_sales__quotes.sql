with source as (
    select *
    from {{ ref("base_tools_trailer_retail_sales__quotes") }}
),

renamed as (
    select
        -- timestamps / dates
        _es_update_timestamp,
        _es_load_timestamp,
        created_at,
        estimated_delivery_date,
        gm_dsm_approved_at,

        -- booleans
        is_deleted,
        saas_taxable,

        -- integers
        quote_pk_id,
        quote_id,
        company_id,
        salesperson_user_id,
        secondary_salesperson_user_id,
        market_id,
        delivery_zip_code,
        invoice_id,
        delivery_location_id,

        -- numerics
        down_payment,
        fuel_surcharge,
        other_tax,
        tax_amount,
        delivery_latitude,
        delivery_longitude,

        -- strings
        payment_method,
        delivery_state,
        denial_reason,
        delivery_street_1,
        delivery_street_2,
        delivery_city,
        status,
        created_by,
        sales_folder_url,
        billing_provider,
        internal_note,
        company_name,
        customer_phone_number,
        customer_email_address,
        customer_denial_category,
        customer_notes,
        type_of_sale,
        gm_dsm_approved_by,
        row_number() over (
            partition by quote_id
            order by created_at desc
        ) as version_rank,
        (version_rank = 1) as is_current,
        min(created_at) over (partition by quote_id) as quote_created_at,
        max(iff(status = 'complete', created_at, null)) over (partition by quote_id) as quote_completed_at,
        datediff(day, quote_created_at, quote_completed_at) as days_to_complete
    from source
)

select *
from renamed
