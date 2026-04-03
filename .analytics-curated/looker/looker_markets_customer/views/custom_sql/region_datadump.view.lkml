#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: region_datadump {
  derived_table: {
    sql: with regions as (
      select x.market_id,
             x.region,
             coalesce(x.MARKET_TYPE, 'KC VLP - Retail Branch') as market_type
      from analytics.public.market_region_xwalk x
      join es_warehouse.public.markets m on x.market_id = m.market_id
      where m.ACTIVE = true and m.COMPANY_ID = 1854),
      --current metrics (count by status)
      current_count_by_status as (
          select m.region,
                 m.market_type,
                 p.asset_inventory_status,
                 count(distinct p.asset_id) as asset_count
          from regions m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          where p.is_rerent = false and asset_type_id = 1
          group by m.region, m.MARKET_TYPE, p.asset_inventory_status
),
      region_count_by_status_pivot as (
      select *
      from current_count_by_status s
      PIVOT (sum(asset_count) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (region, market_type, units_on_rent, units_ready_to_rent, units_soft_down, units_hard_down, units_needs_inspection, units_pending_return, units_assigned, units_make_ready, units_pre_delivered)
),
      --current metrics (oec_on_rent, units_on_rent, unit utilization, financial utilization, discount percentage)
      current_oec_by_status as (
          select m.region,
                 m.MARKET_TYPE,
                 p.asset_inventory_status,
                 ROUND(sum(oec),2) as oec
          from regions m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          where p.is_rerent = false
          group by m.region,
                   m.MARKET_TYPE,
                   p.asset_inventory_status
),
      region_oec_by_status_pivot as (
      select *
      from current_oec_by_status s
      PIVOT (sum(oec) for asset_inventory_status in ('On Rent', 'Ready To Rent', 'Soft Down', 'Hard Down', 'Needs Inspection', 'Pending Return', 'Assigned', 'Make Ready', 'Pre-Delivered')) as p
              (region, market_type, oec_on_rent, oec_ready_to_rent, oec_soft_down, oec_hard_down, oec_needs_inspection, oec_pending_return, oec_assigned, oec_make_ready, oec_pre_delivered)
),
      combine_by_status as (
          select
                 c.*,
                 o.oec_on_rent,
                 o.oec_ready_to_rent,
                 o.oec_soft_down,
                 o.oec_hard_down,
                 o.oec_needs_inspection,
                 o.oec_pending_return,
                 o.oec_assigned,
                 o.oec_make_ready,
                 o.oec_pre_delivered
          from region_count_by_status_pivot c
          join region_oec_by_status_pivot o on c.region = o.region and c.market_type = o.market_type
),
      total_oec_for_region as (
          select region,
                 sum(oec_on_rent) as total_oec_on_rent,
                 sum(oec_ready_to_rent) as total_oec_ready_to_rent,
                 sum(oec_soft_down) as total_oec_soft_down,
                 sum(oec_hard_down) as total_oec_hard_down,
                 sum(oec_needs_inspection) as total_oec_needs_inspection,
                 sum(oec_pending_return) as total_oec_pending_return,
                 sum(oec_assigned) as total_oec_assigned,
                 sum(oec_make_ready) as total_oec_make_ready,
                 sum(oec_pre_delivered) as total_oec_pre_delivered
          from combine_by_status
          group by region
),
      current_discount_percentage as (
          select m.region,
                 m.market_type,
                 sum(rp.percent_discount),
                 sum(rp.online_rate),
                 case when sum(rp.PERCENT_DISCOUNT) is not null and sum(rp.ONLINE_RATE) != 0
                     then (sum(rp.PERCENT_DISCOUNT*rp.ONLINE_RATE)/sum(rp.online_rate))
                 end as discount_percentage
          from regions m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          left join analytics.public.RATEACHIEVEMENT_POINTS rp on p.asset_id = rp.asset_id
          where p.is_rerent = false and rp.invoice_date_created >= DATEADD('DAY', -30, current_date)
          group by m.region, m.market_type
),
      total_discount_percentage as (
          select m.region,
                 sum(rp.percent_discount),
                 sum(rp.online_rate),
                 case when sum(rp.PERCENT_DISCOUNT) is not null and sum(rp.ONLINE_RATE) != 0
                     then (sum(rp.PERCENT_DISCOUNT*rp.ONLINE_RATE)/sum(rp.online_rate))
                 end as total_discount_percentage
          from regions m
          left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
          left join analytics.public.RATEACHIEVEMENT_POINTS rp on p.asset_id = rp.asset_id
          where p.is_rerent = false and rp.invoice_date_created >= DATEADD('DAY', -30, current_date)
          group by m.region
),
      current_unit_utilization as (
          select region,
                 market_type,
                 sum(iff(asset_inventory_status = 'On Rent', asset_count, 0))/sum(asset_count) as unit_utilization
          from current_count_by_status
          group by region, market_type
),
      total_unit_utilization as (
          select region,
                 sum(iff(asset_inventory_status = 'On Rent', asset_count, 0))/sum(asset_count) as total_unit_utilization
          from current_count_by_status
          group by region
),
      current_financial_utilization as (
              select m.region,
                     m.market_type,
                     li.rental_revenue as rental_revenue,
                     sum(p.oec) as total_oec,
                     IFF(li.rental_revenue is null or li.rental_revenue = 0, 0, li.rental_revenue * 365 / 31 / total_oec) as financial_utilization
              from regions m
              left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
   --- May want to left join here to pull in KC VLP
              left join (select m.region, m.market_type, sum(l.amount) as rental_revenue from regions m
                                                                     left join analytics.public.v_line_items l on l.branch_id = m.market_id
                    where  l.line_item_type_id in (6, 8, 108, 109) and l.gl_billing_approved_date >= DATEADD('DAY', -31, current_date)
                    group by m.region, m.market_type) li
              on m.region = li.region and m.market_type = li.market_type
              where p.asset_type_id = 1
          group by m.region, m.market_type,rental_revenue
),
      total_financial_utilization as (
          select m.region,
                     li.rental_revenue as rental_revenue,
                     sum(p.oec) as total_oec,
                     IFF(li.rental_revenue is null or li.rental_revenue = 0, 0, li.rental_revenue * 365 / 31 / total_oec) as total_financial_utilization_for_region
              from regions m
              left join analytics.asset_details.asset_physical p on p.rental_branch_id = m.market_id
   --- May want to left join here to pull in KC VLP
              left join (select m.region, sum(l.amount) as rental_revenue from regions m
                                                                     left join analytics.public.v_line_items l on l.branch_id = m.market_id
                    where  l.line_item_type_id in (6, 8, 108, 109) and l.gl_billing_approved_date >= DATEADD('DAY', -31, current_date)
                    group by m.region) li
              on m.region = li.region
              where p.asset_type_id = 1
          group by m.region, rental_revenue
      ),
      region_goals as (
          select m.region,
                 m.market_type,
                 date_trunc('month', g.months)::DATE as goal_month,
                 sum(g.revenue_goals) as goal,
                 row_number() over (partition by m.region, market_type, goal_month order by m.region, m.market_type) as rn
          from regions m
          left join analytics.public.MARKET_GOALS g on g.market_id = m.market_id
          where (goal_month between add_months(current_date, -2) and date_trunc('month', current_date)) and end_date is null
          group by m.region, m.market_type, goal_month
),
      region_goals_pivot as (
      select *
      from (select region, market_type, goal_month, goal from region_goals where rn = 1)
      PIVOT (sum(goal) for goal_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (region, market_type, prev_month_goal, current_month_goal)
      order by region
),
      region_rental_revenue as (
          select m.region,
                 m.market_type,
                 date_trunc('month', li.gl_billing_approved_date)::DATE as revenue_month,
                 sum(li.amount) as rental_revenue,
                 row_number() over (partition by m.region, m.market_type, revenue_month order by m.region) as rn
          from regions m
          left join analytics.public.v_line_items li on m.market_id = li.branch_id
          where li.line_item_type_id in (8, 6, 108, 109) and li.gl_billing_approved_date >= add_months(current_date, -2)
          group by m.region, m.market_type, revenue_month
),
      region_rental_revenue_pivot as (
          select *
      from (select region, market_type, revenue_month, rental_revenue from region_rental_revenue where rn = 1)
      PIVOT (sum(rental_revenue) for revenue_month in (date_trunc('month', add_months(current_date, -1)), date_trunc('month', current_date))) as p (region, market_type, prev_month_revenue, current_month_revenue)
      order by region
),
      combine as (
      select coalesce(r.region, g.region)::INT as region,
             coalesce(r.market_type, g.market_type) as market_type,
             ROUND(r.prev_month_revenue,2) as prev_month_revenue,
             ROUND(r.current_month_revenue,2) as current_month_revenue,
             ROUND(g.prev_month_goal,2) as prev_month_revenue_goal,
             ROUND(g.current_month_goal,2) as current_month_revenue_goal
      from region_goals_pivot g
      full outer join region_rental_revenue_pivot r on g.region = r.region and g.market_type = r.market_type
),
      region_market_type_group as (
         select REGION as region_id,
                REGION_NAME as region_name,
                coalesce(MARKET_TYPE, 'KC VLP - Retail Branch') as market_type
            from ANALYTICS.PUBLIC.MARKET_REGION_XWALK
         group by region_id,
                  region_name,
                  market_type
)
      select xw.region_id,
             xw.region_name,
             xw.market_type,
             c.current_month_revenue,
             c.current_month_revenue_goal,
             c.prev_month_revenue,
             c.prev_month_revenue_goal,
             ROUND(u.unit_utilization, 4) as unit_utilization,
             tuu.total_unit_utilization,
             ROUND(f.financial_utilization, 4) as financial_utilization,
             tfu.total_financial_utilization_for_region,
             ROUND(d.discount_percentage, 4) as discount_percentage,
             tdp.total_discount_percentage,
             s.* exclude (region, market_type),
             tofr.* exclude region
      from region_market_type_group xw
      join combine_by_status s on xw.region_id = s.region and xw.market_type = s.market_type
      left join total_financial_utilization tfu on tfu.region = xw.region_id
      left join total_unit_utilization tuu on tuu.region = xw.region_id
      left join total_discount_percentage tdp on tdp.region = xw.region_id
      left join total_oec_for_region tofr on tofr.region = xw.region_id
      left join combine c on c.region = xw.region_id and c.market_type = xw.market_type
      left join current_discount_percentage d on c.region = d.region and c.market_type = d.market_type
      left join current_unit_utilization u on c.region = u.region and c.market_type = u.market_type
      left join current_financial_utilization f on c.region = f.region and c.market_type = f.market_type ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: current_month_revenue {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: current_month_revenue_goal {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_REVENUE_GOAL" ;;
    value_format_name: usd_0
  }

  dimension: prev_month_revenue {
    type: number
    sql: ${TABLE}."PREV_MONTH_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: prev_month_revenue_goal {
    type: number
    sql: ${TABLE}."PREV_MONTH_REVENUE_GOAL" ;;
    value_format_name: usd_0
  }

  dimension: unit_utilization {
    type: number
    sql: ${TABLE}."UNIT_UTILIZATION" ;;
    value_format_name: percent_1
  }

  dimension: financial_utilization {
    type: number
    sql: ${TABLE}."FINANCIAL_UTILIZATION" ;;
    value_format_name: percent_1
  }

  dimension: discount_percentage {
    type: number
    sql: ${TABLE}."DISCOUNT_PERCENTAGE" ;;
    value_format_name: percent_1
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
    value_format_name: usd_0
  }

  dimension: oec_ready_to_rent {
    type: number
    sql: ${TABLE}."OEC_READY_TO_RENT" ;;
    value_format_name: usd_0
  }

  dimension: oec_soft_down {
    type: number
    sql: ${TABLE}."OEC_SOFT_DOWN" ;;
    value_format_name: usd_0
  }

  dimension: oec_hard_down {
    type: number
    sql: ${TABLE}."OEC_HARD_DOWN" ;;
    value_format_name: usd_0
  }

  dimension: oec_needs_inspection {
    type: number
    sql: ${TABLE}."OEC_NEEDS_INSPECTION" ;;
    value_format_name: usd_0
  }

  dimension: oec_pending_return {
    type: number
    sql: ${TABLE}."OEC_PENDING_RETURN" ;;
    value_format_name: usd_0
  }

  dimension: oec_assigned {
    type: number
    sql: ${TABLE}."OEC_ASSIGNED" ;;
    value_format_name: usd_0
  }

  dimension: oec_make_ready {
    type: number
    sql: ${TABLE}."OEC_MAKE_READY" ;;
    value_format_name: usd_0
  }

  dimension: oec_pre_delivered {
    type: number
    sql: ${TABLE}."OEC_PRE_DELIVERED" ;;
    value_format_name: usd_0
  }

  dimension: total_unit_utilization {
    type: number
    sql: ${TABLE}."TOTAL_UNIT_UTILIZATION" ;;
    value_format_name: percent_1
  }

  dimension: total_finacial_utilization {
    type: number
    sql: ${TABLE}."TOTAL_FINANCIAL_UTILIZATION_FOR_REGION" ;;
    value_format_name: percent_1
  }

  dimension: total_discount_percentage {
    type: number
    sql: ${TABLE}."TOTAL_DISCOUNT_PERCENTAGE" ;;
    value_format_name: percent_1
  }

  dimension: total_oec_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_ready_to_rent{
    type: number
    sql: ${TABLE}."TOTAL_OEC_READY_TO_RENT" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_soft_down {
    type: number
    sql: ${TABLE}."TOTAL_OEC_SOFT_DOWN" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_hard_down {
    type: number
    sql: ${TABLE}."TOTAL_OEC_HARD_DOWN" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_needs_inspection {
    type: number
    sql: ${TABLE}."TOTAL_OEC_NEEDS_INSPECTION" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_pending_return {
    type: number
    sql: ${TABLE}."TOTAL_OEC_PENDING_RETURN" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_assigned {
    type: number
    sql: ${TABLE}."TOTAL_OEC_ASSIGNED" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_make_ready {
    type: number
    sql: ${TABLE}."TOTAL_OEC_MAKE_READY" ;;
    value_format_name: usd_0
  }

  dimension: total_oec_pre_delivered {
    type: number
    sql: ${TABLE}."TOTAL_OEC_PRE_DELIVERED" ;;
    value_format_name: usd_0
  }

  measure: current_month_revenue_sum {
    type: sum
    sql: ${current_month_revenue} ;;
    value_format_name: usd_0
  }

  measure: current_month_revenue_goal_sum {
    type: sum
    sql: ${current_month_revenue_goal} ;;
    value_format_name: usd_0
  }

  measure: prev_month_revenue_sum {
    type: sum
    sql: ${prev_month_revenue} ;;
    value_format_name: usd_0
  }

  measure: prev_month_revenue_goal_sum {
    type: sum
    sql: ${prev_month_revenue_goal} ;;
    value_format_name: usd_0
  }

  measure: unit_utilization_sum {
    type: sum
    sql: ${unit_utilization} ;;
    value_format_name: percent_1
  }

  measure: financial_utilization_sum {
    type: sum
    sql: ${financial_utilization} ;;
    value_format_name: percent_1
  }

  measure: discount_percentage_sum {
    type: sum
    sql: ${discount_percentage} ;;
    value_format_name: percent_1
  }

  measure: units_on_rent_sum {
    type: sum
    sql: ${units_on_rent} ;;
  }

  measure: units_ready_to_rent_sum {
    type: sum
    sql: ${units_ready_to_rent} ;;
  }

  measure: units_soft_down_sum {
    type: sum
    sql: ${units_soft_down} ;;
  }

  measure: units_hard_down_sum {
    type: sum
    sql: ${units_hard_down} ;;
  }

  measure: units_needs_inspection_sum {
    type: sum
    sql: ${units_needs_inspection} ;;
  }

  measure: units_pending_return_sum {
    type: sum
    sql: ${units_pending_return} ;;
  }

  measure: units_assigned_sum {
    type: sum
    sql: ${units_assigned} ;;
  }

  measure: units_make_ready_sum {
    type: sum
    sql: ${units_make_ready} ;;
  }

  measure: units_pre_delivered_sum {
    type: sum
    sql: ${units_pre_delivered} ;;
  }

  measure: oec_on_rent_sum {
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }

  measure: oec_ready_to_rent_sum {
    type: sum
    sql: ${oec_ready_to_rent} ;;
    value_format_name: usd_0
  }

  measure: oec_soft_down_sum {
    type: sum
    sql: ${oec_soft_down} ;;
    value_format_name: usd_0
  }

  measure: oec_hard_down_sum {
    type: sum
    sql: ${oec_hard_down} ;;
    value_format_name: usd_0
  }

  measure: oec_needs_inspection_sum {
    type: sum
    sql: ${oec_needs_inspection} ;;
    value_format_name: usd_0
  }

  measure: oec_pending_return_sum {
    type: sum
    sql: ${oec_pending_return} ;;
    value_format_name: usd_0
  }

  measure: oec_assigned_sum {
    type: sum
    sql: ${oec_assigned} ;;
    value_format_name: usd_0
  }

  measure: oec_make_ready_sum {
    type: sum
    sql: ${oec_make_ready} ;;
    value_format_name: usd_0
  }

  measure: oec_pre_delivered_sum {
    type: sum
    sql: ${oec_pre_delivered} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      region_id,
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
