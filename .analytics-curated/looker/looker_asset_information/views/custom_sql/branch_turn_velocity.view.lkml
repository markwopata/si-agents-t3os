view: branch_turn_velocity {
    derived_table: {
      sql:with get_past_days as
    (
    select
    dateadd(
    day,
    '-' || row_number() over (order by null),
    dateadd(day, '+1', current_date())
    ) as generated_date
    from table (generator(rowcount => 1095)) --3years worth of days including weekends
    )

,filter_status as( -- accounting for status flipping back when it wasn't truly ready to rent, or rental was extended
   select asset_id
, asset_inventory_status
, date_start
, date_end
, lead(asset_inventory_status) over (partition by asset_id order by date_start) next_status
from "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS"
where asset_inventory_status in ('On Rent', 'Ready To Rent')
order by asset_id, date_start
)

, dates as (
  select asset_id
, asset_inventory_status
, date_start
, date_end return_date
, lead(date_start) over (partition by asset_id order by date_start) rent_ready
, case when (lead(date_start) over (partition by asset_id order by date_start)) is null
then current_date
else (lead(date_start) over (partition by asset_id order by date_start))
end rent_ready_else_today
, case when (lead(date_start) over (partition by asset_id order by date_start)) is null then 'no end date'  else 'has end date' end end_date_flag
from filter_status
where (next_status is null --still need null inorder to get the rent_ready date (start date from the next row)
or asset_inventory_status != next_status) -- accounting for status flipping back when it wasn't truly ready to rent, or rental was extended
  order by asset_id, date_start
 )

,detail as(
select b.rental_branch_id market_id
, m.market_name
, b.date_start rsp_start
, b.date_end rsp_end
, a.asset_id
, return_date
, rent_ready_else_today
, iff(b.date_start>= return_date, b.date_start, null) rsp_turn_start
, iff(b.date_end<=rent_ready_else_today, b.date_end, null) rsp_turn_end
, coalesce(rsp_turn_start,return_date) turn_start
, coalesce(rsp_turn_end,rent_ready_else_today) turn_end
, end_date_flag
, datediff(days,turn_start,turn_end) turnaround_days
from dates d
join "ES_WAREHOUSE"."SCD"."SCD_ASSET_RSP" b
on d.asset_id=b.asset_id
and ((return_date::date > b.date_start::date and return_date::date <b.date_end::date ) --allows for multiple branch break
    or (rent_ready_else_today::date > b.date_start::date and rent_ready_else_today::date <b.date_end::date ))
join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" m
on b.rental_branch_id = m.market_id
join ES_WAREHOUSE.PUBLIC.assets a
on a.asset_id = d.asset_id
where asset_inventory_status = 'On Rent' -- this is not truly on rent, it is assets that have been returned from a rental
and year(return_date)!=9999 --this is assets that are truly on rent right now
  and m.market_type_id=1
order by a.asset_id, return_date
)

,turn as(
  select distinct market_id
,market_name
, asset_id
, turn_start --, return_date
, turn_end --, rent_ready_else_today
  , end_date_flag --added flag
, turnaround_days
, '1854' company_id
from detail
WHERE NOT (turnaround_days < 10 AND end_date_flag = 'no end date')
order by asset_id, turn_start --,return_date
)

,company as(
  select
'1854' company_id
,avg (turnaround_days) co_avg_turn_days
from turn
)

,average_comparison as(
  select
distinct market_id
, market_name
, avg(turnaround_days)over (partition by market_id) avg_turn_days
, co_avg_turn_days
, count (market_id) over (partition by market_id) occurences
from turn t
join company c
on t.company_id = c.company_id
order by market_id
)

, percent AS (
SELECT market_id,
100*SUM(CASE WHEN (turnaround_days>=10 and end_date_flag ='has end date') THEN 1 ELSE 0 END)/COUNT(*) percent_new
FROM detail
group by market_id
)

  select
  ac.*
  ,p.percent_new as percent_above_threshold
  , case when (avg_turn_days -2)> co_avg_turn_days then 'Needs Improvement'
  when (avg_turn_days +2)< co_avg_turn_days then 'Good'
  else 'OK' end avg_turn_dayscomp
  from average_comparison ac
  left join percent p on ac.market_id = p.market_id

          ;;
    }

    dimension: market_id {
      type: number
      sql: ${TABLE}.MARKET_ID ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}.MARKET_NAME ;;
    }

    dimension: avg_turn_days {
      type: number
      sql: ${TABLE}.AVG_TURN_DAYS ;;
    }

    dimension: co_avg_turn_days {
      type: number
      sql: ${TABLE}.CO_AVG_TURN_DAYS ;;
    }

    dimension: occurences {
      type: number
      sql: ${TABLE}.OCCURENCES ;;
    }

    dimension: percent_above_threshold {
      type: number
      sql: ${TABLE}.PERCENT_ABOVE_THRESHOLD ;;
    }

    dimension: avg_turn_dayscomp {
      type: string
      sql: ${TABLE}.AVG_TURN_DAYSCOMP ;;
    }

}
