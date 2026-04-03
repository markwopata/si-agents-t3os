{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Remove outdated first-order records when orders are reassigned, cancelled, deleted, or lose their salesperson
        DELETE FROM {{ this }} t
        WHERE (
            -- Only check records where the order or salesperson recently changed (limit scanning the entire table)
            t.order_id IN (
                SELECT order_id
                FROM {{ ref('platform', 'orders') }}
                WHERE {{ filter_source_updates('_orders_effective_start_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }}
                   OR (_orders_effective_delete_utc_datetime is not null
                       AND {{ filter_source_updates('_orders_effective_delete_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }})
            )
            OR t.order_id IN (
                SELECT order_id
                FROM {{ ref('platform', 'order_salespersons') }}
                WHERE salesperson_type_id = 1
                AND (
                    {{ filter_source_updates('_order_salespersons_effective_start_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }}
                    OR (_order_salespersons_effective_delete_utc_datetime is not null
                        AND {{ filter_source_updates('_order_salespersons_effective_delete_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }})
                )
            )
        )
        -- Delete if no qualifying order exists for this company (matching company_id + order_id with active salesperson)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('platform', 'orders') }} o
            JOIN {{ ref('platform', 'order_salespersons') }} os ON o.order_id = os.order_id
            WHERE o.company_id = t.company_id
              AND o.order_id = t.order_id
              AND o.order_status_id <> 8
              AND o.deleted = FALSE
              AND o._orders_effective_delete_utc_datetime is null
              AND os.salesperson_type_id = 1
              AND os._order_salespersons_effective_delete_utc_datetime is null
        )
        {%- endif -%}"
    ]
) }}

 {# Get the first order per company (by date_created) where:
  - The order is not cancelled (order_status_id <> 8)
  - The order is not deleted (_orders_effective_delete_utc_datetime is null)
  - The order has a salesperson (JOIN current_active_salespeople)
  - The salesperson is not deleted (_order_salespersons_effective_delete_utc_datetime is null) #}

with

{% if is_incremental() -%}
-- Capture orders where salesperson changed (new or deleted)
updated_order_salespersons as (
    select distinct order_id
    from {{ ref('platform', 'order_salespersons') }}
    WHERE salesperson_type_id = 1
    AND (
        -- handle new salespersons
        ({{ filter_source_updates('_order_salespersons_effective_start_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }})
        -- handle salespersons that were deleted from the system
        OR
        (_order_salespersons_effective_delete_utc_datetime is not null
            and {{ filter_source_updates('_order_salespersons_effective_delete_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }}
        )
    )
),

-- Capture orders that changed
updated_orders as (
    select order_id, company_id
    from {{ ref('platform','orders') }}
    WHERE (
        -- handle new orders
        ({{ filter_source_updates('_orders_effective_start_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }})
        -- handle orders that were deleted from the system
        OR
        (_orders_effective_delete_utc_datetime is not null
            and {{ filter_source_updates('_orders_effective_delete_utc_datetime', watermark_column='_source_updated_at', buffer_amount=2, time_unit='hour', append_only=true) }}
        )
    )
),

-- Identify ALL companies that need reprocessing
impacted_companies as (
    -- Companies with order changes
    select distinct company_id
    from updated_orders

    UNION

    -- Companies where the order was reassigned (old company)
    select distinct company_id
    from {{ this }}
    where order_id in (select order_id from updated_orders)

    UNION

    -- Companies where salesperson changed on their orders
    select distinct company_id
    from {{ this }}
    where order_id in (select order_id from updated_order_salespersons)
),
{% endif -%}

-- All active salespeople (always full table scan)
current_active_salespeople as (
    select order_id
        , _order_salespersons_effective_start_utc_datetime
    from {{ ref('platform', 'order_salespersons') }}
    WHERE salesperson_type_id = 1
    AND _order_salespersons_effective_delete_utc_datetime is null
),

-- Load orders (full table in full refresh, only impacted companies in incremental)
orders_base as (
    SELECT order_id
        , order_status_id
        , date_created
        , company_id
        , deleted
        , _orders_effective_delete_utc_datetime
        , _orders_effective_start_utc_datetime
    FROM {{ ref('platform','orders') }}
    {% if is_incremental() -%}
    WHERE company_id in (select company_id from impacted_companies)
    {% endif -%}
)

SELECT
    ob.company_id
    , ob.order_id
    , ob.date_created

    , GREATEST(
        ob._orders_effective_start_utc_datetime,
        cas._order_salespersons_effective_start_utc_datetime
    ) AS _source_updated_at -- watermark
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM orders_base ob
JOIN current_active_salespeople cas
    ON ob.order_id = cas.order_id

WHERE ob.order_status_id <> 8  -- not cancelled
AND ob.deleted = FALSE  -- not soft-deleted
AND ob._orders_effective_delete_utc_datetime is null  -- not hard-deleted

QUALIFY ROW_NUMBER() OVER (PARTITION BY ob.company_id ORDER BY ob.date_created ASC) = 1