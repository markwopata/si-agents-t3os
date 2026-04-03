with payout_assignment_adjustment1 as (
    -- For these 5 assets, one of the assignment rows (ea asset) can't be right at all.
    -- Then the date_end has to be adjusted for 1 row (ea asset).
    select
        ppa1.payout_program_assignment_id,
        ppa1.payout_program_id,
        ppa1.asset_id,
        ppa1.date_start,
        lead(ppa1.date_start)
            over (
                partition by ppa1.asset_id
                order by ppa1.date_start
            ) as next_date_start,
        case
            when next_date_start <= dateadd(days, 3, ppa1.date_end)
                then next_date_start
            else ppa1.date_end
        end as date_end_adj1,
        ppa1.date_end,
        ppa1.date_start as original_date_start,
        ppa1.date_end as original_date_end
    from {{ ref("stg_es_warehouse_public__payout_program_assignments") }} as ppa1
    where 1 = 1
        and ppa1.payout_program_assignment_id not in (
            2450,
            2453,
            2451,
            2452
        )
        and ppa1.asset_id in (
            107559,
            107878,
            108066,
            135051,
            75258
        )
    order by ppa1.asset_id, ppa1.date_start
),

payout_program_assignments_adj_2 as (
    -- Combine adjusted data for the 5 assets with rest of ppa data.
    -- Also drop 2 more payout_program_assignment_id which are probably erroneous.
    select
        ppa.payout_program_assignment_id,
        ppa.payout_program_id,
        ppa.asset_id,
        ppa.date_start,
        ppa.date_end,
        ppa.date_start as original_date_start,
        ppa.date_end as original_date_end
    from {{ ref("stg_es_warehouse_public__payout_program_assignments") }} as ppa
    where ppa.asset_id not in (select paa1_2.asset_id from payout_assignment_adjustment1 as paa1_2)
        and ppa.payout_program_assignment_id not in (
            1983, /* This one seems like an error it was put on ppid 5 on the 4th after
            putting it on ppid 6 on 1/1 for 2 months */
            849, /* asset was put on another payout program 14 hours later, assume that one
            is the correct one */
            2367 /* the one overlaps in the middle, can't be right (see asset 1801) */
        )
    union all
    select
        paa1.payout_program_assignment_id,
        paa1.payout_program_id,
        paa1.asset_id,
        paa1.date_start,
        paa1.date_end_adj1 as date_end,
        paa1.original_date_start,
        paa1.original_date_end
    from payout_assignment_adjustment1 as paa1
),

payout_program_adjustments_3 as (
    -- Finally, adjust date_end to be the first moment of the next month.
    -- Some assignments were ended the day before the end of the month,
    -- leaving a day where the asset wasn't on a program.
    select
        ppa2.payout_program_assignment_id,
        ppa2.payout_program_id,
        ppa2.asset_id,
        ppa2.date_start,
        lead(ppa2.date_start)
            over (
                partition by ppa2.asset_id
                order by ppa2.date_start
            ) as next_date_start,
        last_day(ppa2.date_end) + 1 as adjust_date_end,
        adjust_date_end <= next_date_start as new_end_date_less_than_next_start,
        -- Per Kevin Chon 4/1/2025, if end date was less than 2 days, consider it the end date.
        adjust_date_end <= dateadd(days, 2, ppa2.date_end) as new_end_date_within_2_days,
        case
            when new_end_date_less_than_next_start and new_end_date_within_2_days
                then adjust_date_end
            when new_end_date_less_than_next_start is null and new_end_date_within_2_days
                then adjust_date_end
            else ppa2.date_end
        end as date_end,
        ppa2.original_date_start,
        ppa2.original_date_end
    from payout_program_assignments_adj_2 as ppa2
    order by asset_id, ppa2.date_start
)

select
    ppa.payout_program_assignment_id,
    pp.payout_program_id,
    pp.name as payout_program_name,
    ppt.payout_program_type_id,
    ppt.name as payout_program_type,
    ppa.asset_id,
    ppa.date_start,
    ppa.date_end,
    ppa.original_date_start,
    ppa.original_date_end,
    pp.asset_payout_percentage,
    (ppt.payout_program_type_id is not null and pp.payout_program_id = 104) as is_payout_program_unpaid, -- PPID 104 indicates that the asset will be added to an
    --active payout program soon, but it hasn't been paid for
    --by the OWN participant yet.
    (ppt.payout_program_type_id is not null and pp.payout_program_id != 104) as is_payout_program_enrolled
from {{ ref('stg_es_warehouse_public__payout_programs') }} as pp
    inner join {{ ref('stg_es_warehouse_public__payout_program_types') }} as ppt
        on pp.payout_program_type_id = ppt.payout_program_type_id
    inner join payout_program_adjustments_3 as ppa
        on pp.payout_program_id = ppa.payout_program_id
where ppa.date_start < ppa.date_end
