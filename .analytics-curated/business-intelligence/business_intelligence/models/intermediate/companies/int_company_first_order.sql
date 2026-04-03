{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Remove outdated first-order records when orders are reassigned, cancelled, or deleted
        DELETE FROM {{ this }} t
        WHERE
            -- Only check records where the order recently changed (limit scanning the entire table)
            t.order_id IN (
                SELECT order_id
                FROM {{ ref('platform', 'orders') }}
                WHERE {{ filter_source_updates('_orders_effective_start_utc_datetime', buffer_amount=1) }}
                   OR {{ filter_source_updates('date_created', buffer_amount=1) }}
                   OR (_orders_effective_delete_utc_datetime is not null
                       AND {{ filter_source_updates('_orders_effective_delete_utc_datetime', buffer_amount=1) }})
            )
        -- Delete if no qualifying order exists for this company (matching company_id + order_id)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('platform', 'orders') }} o
            WHERE o.company_id = t.company_id
              AND o.order_id = t.order_id
              AND o.order_status_id <> 8
              AND o.deleted = FALSE
              AND o._orders_effective_delete_utc_datetime is null
        );
        {%- endif -%}"
    ]
) }} 


with updated_orders as (
    SELECT order_id
        , company_id
    FROM {{ ref('platform','orders') }}

    {% if is_incremental() -%}
    WHERE (
        -- handle new orders
        ({{ filter_source_updates('_orders_effective_start_utc_datetime', buffer_amount=1) }})
        OR {{ filter_source_updates('date_created', buffer_amount=1) }}
        -- handle orders that were deleted from the system
        OR
        (_orders_effective_delete_utc_datetime is not null
            and {{ filter_source_updates('_orders_effective_delete_utc_datetime', buffer_amount=1) }}
        )
    )
    {% endif -%}
)

{% if is_incremental() -%}
, impacted_companies as (
    select company_id
    from updated_orders

    union

    -- handle companies where the order got assigned to a different company
    select company_id
    from {{ this }}
    where order_id in (select order_id from updated_orders)
)
{% endif -%}

, orders_base as (
    SELECT order_id
        , order_status_id
        , date_created
        , company_id
        , deleted
        , _orders_effective_delete_utc_datetime
    FROM {{ ref('platform','orders') }}
    {% if is_incremental() -%}
    WHERE company_id in (select company_id from impacted_companies)
    {% endif -%}
)

SELECT
    company_id
    , order_id
    , date_created

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from orders_base
WHERE order_status_id <> 8  -- exclude cancelled orders
AND deleted = FALSE  -- not soft-deleted
AND _orders_effective_delete_utc_datetime is null  -- not hard-deleted

QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY date_created ASC) = 1