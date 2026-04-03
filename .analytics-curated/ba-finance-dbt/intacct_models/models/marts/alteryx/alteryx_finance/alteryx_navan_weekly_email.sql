select
    b.uuid as booking_uuid,
    listagg(distinct bp.person_name, ', ')
    within group (order by bp.person_name) as traveling_users,
    b.booking_type as booking_type,
    iff(upper(b.booking_type) in ('HOTEL', 'CAR'), round(b.unitary_price, 2)::varchar, '') as per_day_price,
    b.usd_grand_total as total_price,
    b.booking_status,
    b.out_of_policy_violation,
    coalesce(b.cabin, '') as traveled_cabin_class,
    b.vendor,
    b.start_date as booking_start_date,
    b.end_date as booking_end_date,
    to_char(convert_timezone('UTC', 'America/Chicago', b.created::datetime), 'YYYY-MM-DD HH24:MI') as date_purchased,
    b.trip_name,
    b.purpose as trip_purpose,
    bp.person_manager_name as manager_name,
    bp.person_manager_email as manager_email,
    listagg(distinct bp.person_email, ', ')
    within group (order by bp.person_email) as traveling_user_emails
from {{ ref('stg_analytics_navan__booking') }} as b
    left join {{ ref('stg_analytics_navan__booking_passenger') }} as bp
        on b.uuid = bp.booking_uuid
group by all
