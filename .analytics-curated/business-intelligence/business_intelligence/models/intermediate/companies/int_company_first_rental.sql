{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Remove outdated first-rental records when rentals are reassigned, cancelled, or deleted
        DELETE FROM {{ this }} t
        WHERE
            -- Only check records where the rental recently changed (limit scanning the entire table)
            t.rental_id IN (
                SELECT rental_id
                FROM {{ ref('platform', 'rentals') }}
                WHERE {{ filter_source_updates('_rentals_effective_start_utc_datetime', buffer_amount=1) }}
                   OR (_rentals_effective_delete_utc_datetime is not null
                       AND {{ filter_source_updates('_rentals_effective_delete_utc_datetime', buffer_amount=1) }})
            )
        -- Delete if no qualifying rental exists for this company (matching company_id + rental_id)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('platform', 'rentals') }} r
            JOIN {{ ref('platform', 'orders') }} o ON r.order_id = o.order_id
            WHERE o.company_id = t.company_id
              AND r.rental_id = t.rental_id
              AND r.rental_status_id <> 8
              AND r.deleted = FALSE
              AND o.deleted = FALSE
              AND r._rentals_effective_delete_utc_datetime is null
        )
        {%- endif -%}"
    ]
) }} 

with updated_rentals as (
    select r.rental_id
        , r.order_id
        , o.company_id
    from {{ ref('platform','rentals') }} r
    JOIN {{ ref('platform', 'orders') }} o
        ON r.order_id = o.order_id

    {% if is_incremental() -%}
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
    {% endif -%}
)

{% if is_incremental() -%}
, impacted_companies as (
    select company_id
    from updated_rentals

    union

    -- handle companies where the order/rental got assigned to a different company
    select company_id
    from {{ this }}
    where order_id in (select order_id from updated_rentals)

    union

    select company_id
    from {{ this }}
    where rental_id in (select rental_id from updated_rentals)
)
{% endif -%}

, rentals_base as (
    select r.rental_id
        , r.order_id
        , o.company_id
        , r.rental_status_id
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
    company_id
    , rental_id
    , order_id
    , date_created

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM rentals_base
WHERE rental_status_id <> 8  -- cancelled rentals
AND rental_deleted = FALSE  -- not soft-deleted
AND order_deleted = FALSE  -- not soft-deleted
AND _rentals_effective_delete_utc_datetime is null  -- not hard-deleted

QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY date_created ASC) = 1