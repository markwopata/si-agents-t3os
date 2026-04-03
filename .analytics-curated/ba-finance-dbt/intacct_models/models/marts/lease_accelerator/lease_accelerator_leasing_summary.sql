with leasing_summary as (
    select * from {{ ref('int_leasing_summary_assets_pivoted_to_leases' )}}
)

select
    l.schedule_number
    , l.total_rent_local
    , l.funder
    , l.booking_ledger_date
    , l.rental_start
    , l.rental_end
    , l.term
    , l.ledger_code
    , l.status
from leasing_summary l
