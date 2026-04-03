select
    brr.branch_rental_rate_id,
    brr.branch_id,
    brr.branch_id as market_id,
    brr.equipment_class_id,
    brr.rate_type_id,
    rt.name as rate_type_name,
    brr.price_per_hour,
    brr.price_per_day,
    brr.price_per_week,
    brr.price_per_month,
    brr.date_created,
    brr.date_created as start_date,
    brr.date_voided,
    -- We cannot use date voided because it appears the prior rate voiding happens AFTER the new one is created. 
    -- If you use voided date to join, you'll likely get 2 rows of data. Generate end date based on the next row's date created.
    lead(brr.date_created) over (
        partition by
            brr.branch_id,
            brr.equipment_class_id,
            brr.rate_type_id
        order by
            brr.date_created
    ) as end_date,
    brr.created_by_user_id,
    brr.voided_by_user_id,
    brr.call_for_pricing as is_call_for_pricing,
    brr.active as is_active,
    brr._es_update_timestamp
from
    {{ ref('stg_es_warehouse_public__branch_rental_rates') }} as brr
    inner join {{ ref("stg_es_warehouse_public__rate_types") }} as rt
        on brr.rate_type_id = rt.rate_type_id
where
    -- there are several situations where date_voided is before date_created.
    -- A lot of those instances have multiple rows added per set of branch, class, type
    -- with the exact same date_created. This seems to only have happened < 2023-01-01,
    -- so opting for the aggressive filter. Also for the instances I looked at,
    -- the ones where the following condition is flipped just don't make sense date-wise.
    brr.date_created < coalesce(brr.date_voided, '2099-12-31 23:59:59.999'::timestamp_ntz)
    -- this is a hack, for this set of branch/class/rate type, on date_created 2022-08-01,
    -- there's 3 entries and this one doesn't have a voided_date which is impossible
    and brr.branch_rental_rate_id != 2671074
