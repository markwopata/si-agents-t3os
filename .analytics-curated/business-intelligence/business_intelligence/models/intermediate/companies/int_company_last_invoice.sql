{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Remove outdated last-invoice records when invoices are reassigned, unapproved, or deleted
        DELETE FROM {{ this }} t
        WHERE
            -- Only check records where the invoice recently changed (limit scanning the entire table)
            t.invoice_id IN (
                SELECT invoice_id
                FROM {{ ref('platform', 'invoices') }}
                WHERE {{ filter_source_updates('_invoices_effective_start_utc_datetime', buffer_amount=1) }}
                   OR (_invoices_effective_delete_utc_datetime is not null
                       AND {{ filter_source_updates('_invoices_effective_delete_utc_datetime', buffer_amount=1) }})
            )
        -- Delete if no qualifying invoice exists for this company (matching company_id + invoice_id)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ ref('platform', 'invoices') }} i
            WHERE i.company_id = t.company_id
              AND i.invoice_id = t.invoice_id
              AND i._invoices_effective_delete_utc_datetime IS NULL
        );
        {%- endif -%}"
    ]
) }}

with updated_invoices as (
    SELECT invoice_id
        , company_id
    FROM {{ ref('platform', 'invoices') }}

    {% if is_incremental() -%}
    WHERE (
        -- handle new invoices
        ({{ filter_source_updates('_invoices_effective_start_utc_datetime', buffer_amount=1) }})
        -- handle invoices that were deleted from the system
        OR
        (_invoices_effective_delete_utc_datetime is not null
            and {{ filter_source_updates('_invoices_effective_delete_utc_datetime', buffer_amount=1) }}
        )
    )
    {% endif -%}
)

{% if is_incremental() -%}
, impacted_companies as (
    select company_id
    from updated_invoices

    union

    -- handle companies where the invoice got assigned to a different company
    select company_id
    from {{ this }}
    where invoice_id in (select invoice_id from updated_invoices)
)
{% endif -%}

, invoices_base as (
    SELECT invoice_id
        , company_id
        , date_created
        , date_updated
        , start_date
        , end_date
        , _invoices_effective_delete_utc_datetime
    FROM {{ ref('platform', 'invoices') }}
    {% if is_incremental() -%}
    WHERE company_id in (select company_id from impacted_companies)
    {% endif -%}
)

    -- last invoice is determined by latest billing cycle date
SELECT
    company_id
    , invoice_id
    , date_created
    , date_updated
    , start_date as invoice_cycle_start_date
    , end_date as invoice_cycle_end_date
    , datediff(day, end_date, CURRENT_DATE()) as days_since_invoice

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM invoices_base
WHERE _invoices_effective_delete_utc_datetime IS NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY end_date DESC) = 1