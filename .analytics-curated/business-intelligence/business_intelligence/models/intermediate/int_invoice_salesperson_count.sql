{{ config(
    materialized='incremental'
    , unique_key=['invoice_id']
    ,incremental_strategy='delete+insert'
) }}

with updated_invoice_salespeople as (
    select *
    from {{ ref('platform', 'es_warehouse__public__approved_invoice_salespersons')}}

    {% if is_incremental() -%}
    WHERE ({{ filter_incremental_with_buffer_day('_es_update_timestamp', buffer_days=1) }})
    {%- endif -%}
)

SELECT
    invoice_id
    , iff(primary_salesperson_id is not null, 1, 0) as num_primary_salesperson
    , ARRAY_SIZE(secondary_salesperson_ids) AS num_secondary_salesperson
    , COALESCE(num_primary_salesperson, 0) + COALESCE(num_secondary_salesperson, 0) as total_num_salesperson

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp
    
FROM {{ ref('platform', 'es_warehouse__public__approved_invoice_salespersons')}}
WHERE invoice_id in (select invoice_id from updated_invoice_salespeople)