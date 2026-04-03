{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert',
    post_hook=[
        "{% if is_incremental() -%}
        -- Delete rows for companies with a recently-changed rental that now have zero active (non-cancelled, non-deleted) rentals 
        DELETE FROM {{ this }} t
        WHERE t.company_id IN ( 
        -- 1) companies with any recent changes
            SELECT DISTINCT o.company_id
            FROM {{ ref('platform', 'rentals') }} r
            JOIN {{ ref('platform', 'orders') }} o ON r.order_id = o.order_id
            WHERE (
                ( {{ filter_source_updates('r._rentals_effective_start_utc_datetime', buffer_amount=1) }} )
                OR (r._rentals_effective_delete_utc_datetime IS NOT NULL
                    AND {{ filter_source_updates('r._rentals_effective_delete_utc_datetime', buffer_amount=1) }})
            )
        )
        -- 2) companies that don't already have 'Has Rented status'
            AND t.lifetime_rental_status <> 'Has Rented'
        AND NOT EXISTS (
         -- 3) companies that have any active rentals that would still qualify it for a 'Has Rented' status? 
            SELECT 1
            FROM {{ ref('platform', 'int_rentals_relationship_mapping') }} rm
            JOIN {{ ref('platform', 'dim_rentals') }} dr ON rm.rental_id = dr.rental_id
            WHERE rm.customer_company_id = t.company_id
                AND dr.rental_status_id <> 8
                AND rm.deleted = false
        )
        {%- endif -%}"
    ]
) }}

with updated_rentals as (
    select r.rental_id, o.company_id, r._rentals_effective_delete_utc_datetime
    from {{ ref('platform', 'rentals') }} r
    join {{ ref('platform', 'orders') }} o on r.order_id = o.order_id
    where (
        {{ filter_source_updates('r._rentals_effective_start_utc_datetime', buffer_amount=1) }}
        or (r._rentals_effective_delete_utc_datetime is not null
            and {{ filter_source_updates('r._rentals_effective_delete_utc_datetime', buffer_amount=1) }})
    )
   {% if is_incremental() -%}
   and o.company_id not in (select company_id from {{ this }} where lifetime_rental_status = 'Has Rented')
   {%- endif -%}
)

, rentals_base as (
    select
        rm.customer_company_id as company_id
        , rm.rental_id
        , r.rental_status_id
        , rm.deleted
    from {{ ref('platform', 'int_rentals_relationship_mapping') }} rm
    join {{ ref('platform', 'dim_rentals') }} r
        on rm.rental_id = r.rental_id
    {% if is_incremental() -%}
    where rm.customer_company_id in (select company_id from updated_rentals)
    {%- endif -%}
)

select
    company_id
    , case
        when max(case when rental_status_id in (5, 6, 7, 9) then 1 else 0 end) = 1 
        then 'Has Rented'
        when max(case when rental_status_id in (1, 2, 3, 4) then 1 else 0 end) = 1 
        then 'Has Reservation'
        else 'Never Rented'
    end as lifetime_rental_status
    , {{ get_current_timestamp() }} as _updated_recordtimestamp

from rentals_base r 
where rental_status_id <> 8
    and deleted = false
group by 1