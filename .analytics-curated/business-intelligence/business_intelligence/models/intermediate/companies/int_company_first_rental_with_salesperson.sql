{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Remove outdated first-rental records when rentals are reassigned, cancelled, deleted, or lose their salesperson
        DELETE FROM {{ this }} t
        WHERE (
            -- Only check records where the rental or salesperson recently changed (limit scanning the entire table)
            t.rental_id IN (
                SELECT rental_id
                FROM {{ ref('platform', 'rentals') }}
                WHERE {{ filter_source_updates('_rentals_effective_start_utc_datetime', buffer_amount=1) }}
                   OR (_rentals_effective_delete_utc_datetime is not null
                       AND {{ filter_source_updates('_rentals_effective_delete_utc_datetime', buffer_amount=1) }})
            )
            OR t.order_id IN (
                SELECT order_id
                FROM {{ ref('platform', 'order_salespersons') }}
                WHERE salesperson_type_id = 1
                AND (
                    {{ filter_source_updates('_order_salespersons_effective_start_utc_datetime', buffer_amount=1) }}
                    OR (_order_salespersons_effective_delete_utc_datetime is not null
                        AND {{ filter_source_updates('_order_salespersons_effective_delete_utc_datetime', buffer_amount=1) }})
                )
            )
        )
        -- Delete if no qualifying rental exists for this company (matching company_id + rental_id with active salesperson)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('platform', 'rentals') }} r
            JOIN {{ ref('platform', 'orders') }} o ON r.order_id = o.order_id
            JOIN {{ ref('platform', 'order_salespersons') }} os ON r.order_id = os.order_id
            WHERE o.company_id = t.company_id
              AND r.rental_id = t.rental_id
              AND r.rental_status_id <> 8
              AND r.deleted = FALSE
              AND o.deleted = FALSE
              AND r._rentals_effective_delete_utc_datetime is null
              AND os.salesperson_type_id = 1
              AND os._order_salespersons_effective_delete_utc_datetime is null
        )
        {%- endif -%}"
    ]
) }}

 {# Get the first rental per company (by date_created) where:
  - The rental is not cancelled (rental_status_id <> 8)
  - The rental is not deleted (_rentals_effective_delete_utc_datetime is null)
  - The rental's order has a salesperson (JOIN current_active_salespeople)
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
            ({{ filter_source_updates('_order_salespersons_effective_start_utc_datetime', buffer_amount=1) }})
            -- handle salespersons that were deleted from the system
            OR
            (_order_salespersons_effective_delete_utc_datetime is not null
                and {{ filter_source_updates('_order_salespersons_effective_delete_utc_datetime', buffer_amount=1) }}
            )
        )
    ),

    -- Capture rentals that changed
    updated_rentals as (
        select r.rental_id, r.order_id, o.company_id
        from {{ ref('platform','rentals') }} r
        JOIN {{ ref('platform', 'orders') }} o
            ON r.order_id = o.order_id
        WHERE (
            -- handle new rentals
            ({{ filter_source_updates('r._rentals_effective_start_utc_datetime', buffer_amount=1) }})
            OR {{ filter_source_updates('r.date_created', buffer_amount=1) }}
            -- handle rentals that were deleted from the system
            OR
            (r._rentals_effective_delete_utc_datetime is not null
                and {{ filter_source_updates('r._rentals_effective_delete_utc_datetime', buffer_amount=1) }}
            )
        )
    ),

    -- Identify ALL companies that need reprocessing
    impacted_companies as (
        -- Companies with rental changes
        select distinct company_id
        from updated_rentals

        UNION

        -- Companies where the order/rental was reassigned (old company)
        select distinct company_id
        from {{ this }}
        where order_id in (select order_id from updated_rentals)
        or rental_id in (select rental_id from updated_rentals)

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
        from {{ ref('platform', 'order_salespersons') }}
        WHERE salesperson_type_id = 1
        AND _order_salespersons_effective_delete_utc_datetime is null
    ),

    -- Load rentals (full table in full refresh, only impacted companies in incremental)
    rentals_base as (
        select r.rental_id, r.order_id, o.company_id, r.rental_status_id
            , r.date_created
            , r.deleted as rental_deleted
            , o.deleted as order_deleted
            , r._rentals_effective_delete_utc_datetime
        from {{ ref('platform','rentals') }} r
        JOIN {{ ref('platform', 'orders') }} o
            ON r.order_id = o.order_id
        {% if is_incremental() -%}
        WHERE o.company_id in (select company_id from impacted_companies)
        {% endif -%}
    )

SELECT
    rb.company_id
    , rb.rental_id
    , rb.order_id
    , rb.date_created

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM rentals_base rb
JOIN current_active_salespeople cas
    ON rb.order_id = cas.order_id

WHERE rb.rental_status_id <> 8  -- not cancelled
AND rb.rental_deleted = FALSE  -- not soft-deleted
AND rb.order_deleted = FALSE  -- not soft-deleted
AND rb._rentals_effective_delete_utc_datetime is null  -- not hard-deleted

QUALIFY ROW_NUMBER() OVER (PARTITION BY rb.company_id ORDER BY rb.date_created ASC) = 1