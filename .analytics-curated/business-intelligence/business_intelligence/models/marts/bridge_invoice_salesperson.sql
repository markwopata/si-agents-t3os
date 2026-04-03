{{ config(
    materialized='incremental'
    , unique_key=['invoice_key']
    , incremental_strategy='delete+insert'
    , post_hook = [
        "
        delete from {{ this }} as t
        where exists (
            select 1
            from {{ ref('platform','dim_invoices') }} i
            where i.invoice_key = t.invoice_key
                and i.invoice_id = -1
        )
        "
  ]
) }}

with updated_invoice_salespeople as (
    SELECT
        invoice_id
        , billing_approved_date
        , salesperson_user_id
        , salesperson_type
    FROM {{ ref('int_bridge_invoice_salesperson') }}
    {% if is_incremental() -%}
    WHERE ({{ filter_incremental_with_buffer_day('_updated_recordtimestamp', buffer_days=1) }})
    {%- endif -%}
)

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_salesperson as (
        select salesperson_key, user_id, _valid_from, _valid_to
        from {{ ref('dim_salesperson_enhanced') }}
    )

    , cte_invoices as (
        select invoice_key, invoice_id
        from {{ ref('platform', 'dim_invoices') }}
    )

    , cte_full_list as (
        SELECT
            rs.invoice_id
            , i.invoice_key
            , rs.salesperson_user_id
            , u.user_key as salesperson_user_key
            , s.salesperson_key
            , rs.billing_approved_date
            , rs.salesperson_type
            , s._valid_from
            , s._valid_to
        from updated_invoice_salespeople rs
        LEFT JOIN cte_invoices i 
            ON i.invoice_id = rs.invoice_id
        LEFT JOIN cte_users u
            ON u.user_id = rs.salesperson_user_id
        LEFT JOIN cte_salesperson s
            ON s.user_id = rs.salesperson_user_id AND rs.billing_approved_date BETWEEN s._valid_from and s._valid_to
    )

SELECT
    {{ dbt_utils.generate_surrogate_key(
        ['invoice_id', 'salesperson_user_id']) 
    }} AS invoice_salesperson_key
    , COALESCE(invoice_key
        , {{ get_default_key_from_dim(model_name='dim_invoices') }}
    ) AS invoice_key
    , COALESCE(salesperson_user_key
        , {{ get_default_key_from_dim(model_name='dim_users') }}
    ) AS salesperson_user_key
    , COALESCE(salesperson_key 
        , {{ get_default_key_from_dim(model_name='dim_salesperson_enhanced') }}
    ) AS salesperson_key

    , salesperson_type

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from cte_full_list