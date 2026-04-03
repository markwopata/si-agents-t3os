view: delivery_types {
  derived_table: {
    sql:
      select
    m.market_id,
    m.market_name,
    date_trunc(month, d.completed_date) as month_year,
    pp.display,
    m.market_type,
    m.region_name,
    m.district,
    sum(case when d.delivery_type_id = 1 then 1 else 0 end) as num_dropoffs,
    sum(case when d.delivery_type_id = 6 then 1 else 0 end) as num_pickups,
    avg(case when d.delivery_type_id = 1 then d.charge end) as avg_dropoff_charge,
    avg(case when d.delivery_type_id = 6 then d.charge end) as avg_pickup_charge,
    sum(case when d.delivery_type_id = 1 and d.charge = 0 then 1 else 0 end) / nullif(sum(case when d.delivery_type_id = 1 then 1 else 0 end), 0) as pct_zero_charge_dropoffs,
    sum(case when d.delivery_type_id = 6 and d.charge = 0 then 1 else 0 end) / nullif(sum(case when d.delivery_type_id = 6 then 1 else 0 end), 0) as pct_zero_charge_pickups
from es_warehouse.public.deliveries d
join es_warehouse.public.delivery_types dt
    on d.delivery_type_id = dt.delivery_type_id
left join es_warehouse.public.orders o
    on d.order_id = o.order_id
join analytics.branch_earnings.market m
    on o.market_id = m.child_market_id
left join analytics.gs.plexi_periods pp
    on month(d.completed_date) = pp.month_num
    and year(d.completed_date) = pp.year
where d.completed_date >= '2022-01-01'
  and d.delivery_type_id in (1, 6)
  and d.facilitator_type_id <> 3
  and d.asset_id is not null
group by
    m.market_id,
    m.market_name,
    date_trunc(month, d.completed_date),
    pp.display,
    m.market_type,
    m.region_name,
    m.district
order by num_dropoffs desc, avg_dropoff_charge desc

      ;;
  }
  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: delivery_month {
    label: "Delivery Month"
    type: date
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  measure: deliveries {
    label: "Deliveries"
    type: sum
    sql: ${TABLE}."DELIVERIES" ;;
  }

  measure: avg_dropoff_charge {
    label: "Avg Dropoff Charge"
    type: sum
    sql: ${TABLE}."AVG_DROPOFF_CHARGE" ;;
  }

  measure: avg_pickup_charge {
    label: "Avg Pickup Charge"
    type: sum
    sql: ${TABLE}."AVG_PICKUP_CHARGE" ;;
  }

  measure: num_dropoffs {
    label: "# of Dropoffs"
    type: sum
    sql: ${TABLE}."NUM_DROPOFFS" ;;
  }

  measure: num_pickups {
    label: "# of Pickups"
    type: sum
    sql: ${TABLE}."NUM_PICKUPS" ;;
  }

  measure: pct_zero_dollar_pickups {
    label: "$0 Pickup Percent"
    type: average
    sql: ${TABLE}."PCT_ZERO_CHARGE_PICKUPS" ;;
  }

  measure: pct_zero_dollar_dropoffs {
    label: "$0 Dropoff Percent"
    type: average
    sql: ${TABLE}."PCT_ZERO_CHARGE_DROPOFFS" ;;
  }


}
