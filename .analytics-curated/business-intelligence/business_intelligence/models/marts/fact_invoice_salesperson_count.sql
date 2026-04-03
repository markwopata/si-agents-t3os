{{ config(
    materialized='incremental'
    , unique_key=['invoice_key']
    , incremental_strategy='delete+insert'
) }}

with cte_invoices as (
    select invoice_key, invoice_id
    from {{ ref('platform', 'dim_invoices') }}
)

SELECT 
    COALESCE(i.invoice_key
        , {{ get_default_key_from_dim(model_name='dim_invoices') }}
    ) AS invoice_key
    , num_primary_salesperson
    , num_secondary_salesperson
    , total_num_salesperson

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from {{ ref('int_invoice_salesperson_count') }} s
LEFT JOIN cte_invoices i 
    ON i.invoice_id = s.invoice_id
{% if is_incremental() -%}
WHERE (
    {{ filter_incremental_with_buffer_day('_updated_recordtimestamp', buffer_days=1) }}
)
{%- endif -%}