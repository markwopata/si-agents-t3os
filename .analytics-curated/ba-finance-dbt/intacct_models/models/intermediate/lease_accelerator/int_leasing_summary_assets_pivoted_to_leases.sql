with leasing_summary_report as (
    select
        schedule_number,
        max(total_rent_local) as total_rent_local -- using max because only the total rent payment per lease is provided
    from {{ ref('stg_analytics_lease_accelerator__leasing_summary_api_download') }}
    group by
        all

),

aggregated_fields as (
    select
        schedule_number,
        ledger_code,
        funder,
        status,
        max(booking_ledger_date) as booking_ledger_date,
        max(rental_start) as rental_start,
        max(rental_end) as rental_end,
        max(term) as term
    from {{ ref('stg_analytics_lease_accelerator__leasing_summary_api_download') }}
    group by
        all
)

select
    l.schedule_number,
    l.total_rent_local,
    a.funder,
    a.booking_ledger_date,
    a.rental_start,
    a.rental_end,
    a.term,
    a.ledger_code,
    a.status
from leasing_summary_report as l
    inner join aggregated_fields as a
        on l.schedule_number = a.schedule_number
