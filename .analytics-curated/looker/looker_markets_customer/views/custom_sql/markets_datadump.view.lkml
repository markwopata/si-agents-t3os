#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: markets_datadump {
  derived_table: {
    sql: with current_count_by_status as (
          select p.rental_branch_id,
                 p.asset_inventory_status,
                 count(distinct p.asset_id) as asset_count
          from analytics.asset_details.asset_physical p
          where p.is_rerent = false and asset_type_id = 1
          group by p.rental_branch_id, p.asset_inventory_status
          ),
      market_count_by_status_pivot as (
      select *
      from current_count_by_status s
      PIVOT (sum(asset_count) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (rental_branch_id, units_on_rent, units_ready_to_rent, units_soft_down, units_hard_down, units_needs_inspection, units_pending_return, units_assigned, units_make_ready, units_pre_delivered)
      order by rental_branch_id),
      --current metrics (oec_on_rent, units_on_rent, unit utilization, financial utilization, discount percentage)
      current_oec_by_status as (
          select p.rental_branch_id,
                 p.asset_inventory_status,
                 ROUND(sum(oec),2) as oec
          from analytics.asset_details.asset_physical p
          where p.is_rerent = false
          group by p.rental_branch_id
                 , p.asset_inventory_status),
      market_oec_by_status_pivot as (
      select *
      from current_oec_by_status s
      PIVOT (sum(oec) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (rental_branch_id, oec_on_rent, oec_ready_to_rent, oec_soft_down, oec_hard_down, oec_needs_inspection, oec_pending_return, oec_assigned, oec_make_ready, oec_pre_delivered)
      order by rental_branch_id),
      combine_by_status as (
          select
                 c.*,
                 o.* exclude rental_branch_id
          from market_count_by_status_pivot c
          join market_oec_by_status_pivot o on c.rental_branch_id = o.rental_branch_id
      ),
      current_discount_percentage as (
          select p.rental_branch_id,
                 sum(rp.percent_discount),
                 sum(rp.online_rate),
                 case when sum(rp.PERCENT_DISCOUNT) is not null and sum(rp.ONLINE_RATE) != 0
                     then (sum(rp.PERCENT_DISCOUNT*rp.ONLINE_RATE)/sum(rp.online_rate))
                 end as discount_percentage
          from analytics.asset_details.asset_physical p
          left join analytics.public.RATEACHIEVEMENT_POINTS rp on p.asset_id = rp.asset_id
          where p.is_rerent = false and rp.invoice_date_created >= DATEADD('DAY', -30, current_date)
          group by p.rental_branch_id
      ),
      current_unit_utilization as (
          select rental_branch_id as market_id,
                 sum(iff(asset_inventory_status = 'On Rent', asset_count, 0))/sum(asset_count) as unit_utilization
          from current_count_by_status
          group by rental_branch_id
      ),
      current_financial_utilization as (
              select li.branch_id as market_id,
                     li.rental_revenue as rental_revenue,
                     sum(p.oec) as total_oec,
                     IFF(rental_revenue is null or rental_revenue = 0 or total_oec = 0 or total_oec is null, 0, rental_revenue * 365 / 31 / total_oec) as financial_utilization
              from analytics.asset_details.asset_physical p
              join (select l.branch_id, sum(l.amount) as rental_revenue from analytics.public.v_line_items l
                    where  l.line_item_type_id in (6, 8, 108, 109) and l.gl_billing_approved_date >= DATEADD('DAY', -31, current_date)
                    group by l.branch_id) li
              on p.rental_branch_id = li.branch_id
              where p.asset_type_id = 1
          group by market_id, rental_revenue
      ),
      market_goals as (
          select market_id,
                 date_trunc('month', months)::DATE as goal_month,
                 revenue_goals as goal
          from analytics.public.MARKET_GOALS
          where (goal_month between add_months(current_date, -2) and date_trunc('month', current_date)) and end_date is null
          order by market_id, goal_month ),
      market_goals_pivot as (
      select *
      from market_goals
      PIVOT (sum(goal) for goal_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (market_id, prev_month_goal, current_month_goal)
      order by market_id),
      market_rental_revenue as (
          select li.branch_id::INT as market_id,
                 date_trunc('month', li.gl_billing_approved_date)::DATE as revenue_month,
                 sum(li.amount) as rental_revenue
          from analytics.public.v_line_items li
          where li.line_item_type_id in (8, 6, 108, 109) and li.gl_billing_approved_date >= add_months(current_date, -2)
          group by market_id, revenue_month
          ),
      market_rental_revenue_pivot as (
          select *
      from market_rental_revenue
      PIVOT (sum(rental_revenue) for revenue_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (market_id, prev_month_revenue, current_month_revenue)
      order by market_id),
      combine as (
      select coalesce(r.market_id, g.market_id)::INT as market_id,
             ROUND(r.prev_month_revenue,2) as prev_month_revenue,
             ROUND(r.current_month_revenue,2) as current_month_revenue,
             ROUND(g.prev_month_goal,2) as prev_month_revenue_goal,
             ROUND(g.current_month_goal,2) as current_month_revenue_goal
      from market_goals_pivot g
      full outer join market_rental_revenue_pivot r on g.MARKET_ID = r.MARKET_ID)
      select x.market_id,
             x.market_name,
             x.REGION_DISTRICT as district,
             x.region,
             x.REGION_NAME as region_name,
             c.current_month_revenue,
             c.current_month_revenue_goal,
             c.prev_month_revenue,
             c.prev_month_revenue_goal,
             ROUND(u.unit_utilization, 4) as unit_utilization,
             ROUND(f.financial_utilization, 4) as financial_utilization,
             ROUND(d.discount_percentage, 4) as discount_percentage,
             s.* exclude rental_branch_id,
             current_timestamp as record_timestamp
      from analytics.public.market_region_xwalk x
      join es_warehouse.public.markets m on x.market_id = m.market_id
      left join combine c on c.market_id = x.market_id
      left join combine_by_status s on x.market_id = s.rental_branch_id
      left join current_discount_percentage d on x.market_id = d.rental_branch_id
      left join current_unit_utilization u on x.market_id = u.market_id
      left join current_financial_utilization f on x.market_id = f.market_id
      where m.ACTIVE = true and m.COMPANY_ID = 1854
      order by x.region, x.district, x.market_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
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

  set: detail {
    fields: [
        market_id,
  market_name,
  district,
  region,
  region_name,
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
  oec_pre_delivered
    ]
  }
}
