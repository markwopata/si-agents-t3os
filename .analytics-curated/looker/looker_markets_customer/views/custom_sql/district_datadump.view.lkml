#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: district_datadump {
  derived_table: {
    sql: with districts as (
      select x.market_id,
             x.district
      from analytics.public.market_region_xwalk x
      join es_warehouse.public.markets m on x.market_id = m.market_id
      where m.ACTIVE = true and m.COMPANY_ID = 1854),
      --current metrics (count by status)
      current_count_by_status as (
          select m.district,
                 p.asset_inventory_status,
                 count(distinct p.asset_id) as asset_count
          from districts m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          where p.is_rerent = false and asset_type_id = 1
          group by m.district, p.asset_inventory_status
          ),
      district_count_by_status_pivot as (
      select *
      from current_count_by_status s
      PIVOT (sum(asset_count) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (district, units_on_rent, units_ready_to_rent, units_soft_down, units_hard_down, units_needs_inspection, units_pending_return, units_assigned, units_make_ready, units_pre_delivered)
      order by district),
      --current metrics (oec_on_rent, units_on_rent, unit utilization, financial utilization, discount percentage)
      current_oec_by_status as (
          select m.district,
                 p.asset_inventory_status,
                 ROUND(sum(oec),2) as oec
          from districts m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          where p.is_rerent = false
          group by m.district
                 , p.asset_inventory_status),
      district_oec_by_status_pivot as (
      select *
      from current_oec_by_status s
      PIVOT (sum(oec) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (district, oec_on_rent, oec_ready_to_rent, oec_soft_down, oec_hard_down, oec_needs_inspection, oec_pending_return, oec_assigned, oec_make_ready, oec_pre_delivered)
      order by district),
      combine_by_status as (
          select
                 c.*,
                 o.* exclude district
          from district_count_by_status_pivot c
          join district_oec_by_status_pivot o on c.district = o.district
      ),
      current_discount_percentage as (
          select m.district,
                 sum(rp.percent_discount),
                 sum(rp.online_rate),
                 case when sum(rp.PERCENT_DISCOUNT) is not null and sum(rp.ONLINE_RATE) != 0
                     then (sum(rp.PERCENT_DISCOUNT*rp.ONLINE_RATE)/sum(rp.online_rate))
                 end as discount_percentage
          from districts m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          left join analytics.public.RATEACHIEVEMENT_POINTS rp on p.asset_id = rp.asset_id
          where p.is_rerent = false and rp.invoice_date_created >= DATEADD('DAY', -30, current_date)
          group by m.district
      ),
      current_unit_utilization as (
          select district,
                 sum(iff(asset_inventory_status = 'On Rent', asset_count, 0))/sum(asset_count) as unit_utilization
          from current_count_by_status
          group by district
      ),
      current_financial_utilization as (
              select m.district,
                     li.rental_revenue as rental_revenue,
                     sum(p.oec) as total_oec,
                     IFF(li.rental_revenue is null or li.rental_revenue = 0, 0, li.rental_revenue * 365 / 31 / total_oec) as financial_utilization
              from districts m
              left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
              join (select m.district, sum(l.amount) as rental_revenue from districts m
                                                                     left join analytics.public.v_line_items l on l.branch_id = m.market_id
                    where  l.line_item_type_id in (6, 8, 108, 109) and l.gl_billing_approved_date >= DATEADD('DAY', -31, current_date)
                    group by m.district) li
              on m.district = li.district
              where p.asset_type_id = 1
          group by m.district, rental_revenue
      ),
      district_goals as (
          select m.district,
                 date_trunc('month', g.months)::DATE as goal_month,
                 sum(g.revenue_goals) as goal,
                 row_number() over (partition by m.district, goal_month order by m.district) as rn
          from districts m
          left join analytics.public.MARKET_GOALS g on g.market_id = m.market_id
          where (goal_month between add_months(current_date, -2) and date_trunc('month', current_date)) and end_date is null
          group by m.district, goal_month),
      district_goals_pivot as (
      select *
      from (select district, goal_month, goal from district_goals where rn = 1)
      PIVOT (sum(goal) for goal_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (district, prev_month_goal, current_month_goal)
      order by district),
      district_rental_revenue as (
          select m.district,
                 date_trunc('month', li.gl_billing_approved_date)::DATE as revenue_month,
                 sum(li.amount) as rental_revenue,
                 row_number() over (partition by m.district, revenue_month order by m.district) as rn
          from districts m
          left join analytics.public.v_line_items li on m.market_id = li.branch_id
          where li.line_item_type_id in (8, 6, 108, 109) and li.gl_billing_approved_date >= add_months(current_date, -2)
          group by m.district, revenue_month
          ),
      district_rental_revenue_pivot as (
          select *
      from (select district, revenue_month, rental_revenue from district_rental_revenue where rn = 1)
      PIVOT (sum(rental_revenue) for revenue_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (district, prev_month_revenue, current_month_revenue)
      order by district),
      combine as (
      select coalesce(r.district, g.district) as district,
             ROUND(r.prev_month_revenue,2) as prev_month_revenue,
             ROUND(r.current_month_revenue,2) as current_month_revenue,
             ROUND(g.prev_month_goal,2) as prev_month_revenue_goal,
             ROUND(g.current_month_goal,2) as current_month_revenue_goal
      from district_goals_pivot g
      join district_rental_revenue_pivot r on g.district = r.district)
      select c.district,
             c.current_month_revenue,
             c.current_month_revenue_goal,
             c.prev_month_revenue,
             c.prev_month_revenue_goal,
             ROUND(u.unit_utilization, 4) as unit_utilization,
             ROUND(f.financial_utilization, 4) as financial_utilization,
             ROUND(d.discount_percentage, 4) as discount_percentage,
             s.* exclude district,
             current_timestamp as record_timestamp
      from combine c
      join combine_by_status s on c.district = s.district
      join current_discount_percentage d on c.district = d.district
      join current_unit_utilization u on c.district = u.district
      join current_financial_utilization f on c.district = f.district
      order by c.district ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: current_month_revenue {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_REVENUE" ;;
  }

  dimension: current_month_revenue_goal {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_REVENUE_GOAL" ;;
  }

  dimension: prev_month_revenue {
    type: number
    sql: ${TABLE}."PREV_MONTH_REVENUE" ;;
  }

  dimension: prev_month_revenue_goal {
    type: number
    sql: ${TABLE}."PREV_MONTH_REVENUE_GOAL" ;;
  }

  dimension: unit_utilization {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION" ;;
  }

  dimension: financial_utilization {
    type: number
    sql: ${TABLE}."FINANCIAL_UTILIZATION" ;;
  }

  dimension: discount_percentage {
    type: number
    sql: ${TABLE}."DISCOUNT_PERCENTAGE" ;;
  }

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  dimension: units_ready_to_rent {
    type: number
    sql: ${TABLE}."UNITS_READY_TO_RENT" ;;
  }

  dimension: units_soft_down {
    type: number
    sql: ${TABLE}."UNITS_SOFT_DOWN" ;;
  }

  dimension: units_hard_down {
    type: number
    sql: ${TABLE}."UNITS_HARD_DOWN" ;;
  }

  dimension: units_needs_inspection {
    type: number
    sql: ${TABLE}."UNITS_NEEDS_INSPECTION" ;;
  }

  dimension: units_pending_return {
    type: number
    sql: ${TABLE}."UNITS_PENDING_RETURN" ;;
  }

  dimension: units_assigned {
    type: number
    sql: ${TABLE}."UNITS_ASSIGNED" ;;
  }

  dimension: units_make_ready {
    type: number
    sql: ${TABLE}."UNITS_MAKE_READY" ;;
  }

  dimension: units_pre_delivered {
    type: number
    sql: ${TABLE}."UNITS_PRE_DELIVERED" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: oec_ready_to_rent {
    type: number
    sql: ${TABLE}."OEC_READY_TO_RENT" ;;
  }

  dimension: oec_soft_down {
    type: number
    sql: ${TABLE}."OEC_SOFT_DOWN" ;;
  }

  dimension: oec_hard_down {
    type: number
    sql: ${TABLE}."OEC_HARD_DOWN" ;;
  }

  dimension: oec_needs_inspection {
    type: number
    sql: ${TABLE}."OEC_NEEDS_INSPECTION" ;;
  }

  dimension: oec_pending_return {
    type: number
    sql: ${TABLE}."OEC_PENDING_RETURN" ;;
  }

  dimension: oec_assigned {
    type: number
    sql: ${TABLE}."OEC_ASSIGNED" ;;
  }

  dimension: oec_make_ready {
    type: number
    sql: ${TABLE}."OEC_MAKE_READY" ;;
  }

  dimension: oec_pre_delivered {
    type: number
    sql: ${TABLE}."OEC_PRE_DELIVERED" ;;
  }

  dimension_group: record_timestamp {
    type: time
    sql: ${TABLE}."RECORD_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        district,
  current_month_revenue,
  current_month_revenue_goal,
  prev_month_revenue,
  prev_month_revenue_goal,
  unit_utilization,
  financial_utilization,
  discount_percentage,
  units_on_rent,
  units_ready_to_rent,
  units_soft_down,
  units_hard_down,
  units_needs_inspection,
  units_pending_return,
  units_assigned,
  units_make_ready,
  units_pre_delivered,
  oec_on_rent,
  oec_ready_to_rent,
  oec_soft_down,
  oec_hard_down,
  oec_needs_inspection,
  oec_pending_return,
  oec_assigned,
  oec_make_ready,
  oec_pre_delivered,
  record_timestamp_time
    ]
  }
}
