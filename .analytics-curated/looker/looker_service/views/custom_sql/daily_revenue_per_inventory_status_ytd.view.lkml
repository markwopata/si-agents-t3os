view: daily_revenue_per_inventory_status_ytd {
  derived_table: {
    sql:
with daily_rental_revenue as (
select
    date_trunc(month,hu.dte) as the_month,
    a.asset_class,
    hu.market_id,
    count(hu.dte) as rental_days,
    sum(hu.day_rate) as rental_revenue,
    rental_revenue / rental_days as daily_rental_revenue
from analytics.public.historical_utilization hu
inner join es_warehouse.public.assets a
    on hu.asset_id = a.asset_id
where dte >= dateadd(day,-400,current_date)
and in_rental_fleet = true
-- and hu.market_id in (select market_id from analytics.public.market_region_xwalk)
group by
    the_month,
    a.asset_class,
    hu.market_id
)

,asset_market_day as (
select
    hu.dte as the_date,
    hu.asset_id,
    hu.market_id
from analytics.public.historical_utilization hu
inner join es_warehouse.public.assets a
    on hu.asset_id = a.asset_id
where dte >= dateadd(day,-400,current_date)
)

select
    amd.asset_id,
    datediff(day,ais.date_start,iff(date(ais.date_end)>current_date,current_date,ais.date_end)) as days_in_status,
    datediff(day,ais.date_start,amd.the_date) as days_on_status,
    a.asset_class,
    amd.market_id,
    amd.the_date,
    TO_CHAR(amd.the_date::date,'MMMM ')||year(amd.the_date) plexi_period,
    ais.asset_inventory_status,
    drr.daily_rental_revenue
from asset_market_day amd
inner join es_warehouse.public.assets a
    on amd.asset_id = a.asset_id
inner join es_warehouse.scd.scd_asset_inventory_status ais
    on amd.asset_id = ais.asset_id
    and amd.the_date >= ais.date_start and amd.the_date < ais.date_end
inner join daily_rental_revenue drr
    on date_trunc(month,amd.the_date) = drr.the_month
    and a.asset_class = drr.asset_class
    and amd.market_id = drr.market_id ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/assets/asset/{{ asset_id }}/rental-history" target="_blank">{{rendered_value}}</a></font></u> ;;
    value_format: "0"
  }
  dimension: plexi_period { #adding this in to be able to filter using BE periods on the outside hauling dashboard
    type: string
    sql: ${TABLE}."PLEXI_PERIOD" ;;
  }

  dimension: days_in_status {
    type: number
    sql: ${TABLE}."DAYS_IN_STATUS" ;;
  }

  dimension: days_on_status {
    type: number
    sql: ${TABLE}."DAYS_ON_STATUS" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }

  dimension_group: the_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."THE_DATE" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: daily_rental_revenue {
    type: number
    sql: ${TABLE}."DAILY_RENTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  measure: days_of_pending_return {
    type: count
    # sql: ${the_date_date} ;;
  }

  measure: lost_revenue {
    type: sum
    sql: ${daily_rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: market_lost_revenue {
    type: sum
    sql: ${daily_rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [market_month_to_asset*]
  }

  measure: sum_of_revenue_by_month {
    type: sum
    sql: ${daily_rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [month_to_market*]
  }

  set: month_to_market {
    fields: [market_region_xwalk.market_name,
            days_of_pending_return,
            market_lost_revenue]
  }

  set: market_month_to_asset {
    fields: [asset_id,
            asset_class,
            market_region_xwalk.market_name,
            days_in_status,
            days_of_pending_return,
            daily_rental_revenue,
            lost_revenue]
  }
}
