{{ config(
    materialized='incremental'
    , unique_key=['invoice_id']
    ,incremental_strategy='delete+insert'
) }}

with updated_invoices as (
    select *
    from {{ ref('platform', 'es_warehouse__public__approved_invoice_salespersons')}}

    {% if is_incremental() -%}
    WHERE ({{ filter_incremental_with_buffer_day('_es_update_timestamp', buffer_days=1) }})
    {%- endif -%}
)

    , primary_salesperson as (
        select
            invoice_id
            , billing_approved_date
            , primary_salesperson_id as salesperson_user_id
            , 'Primary' as salesperson_type
        from updated_invoices
    )

    -- flatten list
    , secondary_salesperson as (
        select
            i.invoice_id
            , i.billing_approved_date
            , TRY_TO_NUMBER(f.value::string) as salesperson_user_id
            , 'Secondary' as salesperson_type
        from updated_invoices i
        CROSS JOIN LATERAL FLATTEN(input => i.secondary_salesperson_ids) f
        WHERE f.value IS NOT NULL
    )

    , primary_and_secondary as (
        SELECT
            invoice_id
            , billing_approved_date
            , salesperson_user_id
            , salesperson_type
        from primary_salesperson
        UNION ALL
        SELECT
            invoice_id
            , billing_approved_date
            , salesperson_user_id
            , salesperson_type
        from secondary_salesperson
    )

SELECT
    invoice_id
    , billing_approved_date
    , salesperson_user_id
    , salesperson_type

    ,{{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM primary_and_secondary