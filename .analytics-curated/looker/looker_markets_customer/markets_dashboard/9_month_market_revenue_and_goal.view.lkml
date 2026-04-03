
view: 9_month_market_revenue_and_goal {
  derived_table: {
    sql:
    -- Now instead of 9 months there are at 14
    with last_nine_months as (
select series::date as date,
       market_id
from
     table(es_warehouse.public.generate_series(
     dateadd(month, -14, date_trunc(month,current_date))::timestamp_tz,
     date_trunc(month,current_date)::timestamp_tz,
     'month'))
left join analytics.public.market_region_xwalk
where division_name = 'Equipment Rental'
),
monthly_market_revenue as (
select m.MARKET_ID,
       m.MARKET_NAME,
       m.market_type,
       sum(ild.invoice_line_details_amount) as rental_revenue,
       date_trunc(month, dd.date) as revenue_month
from platform.gold.v_line_items r
         JOIN platform.gold.v_invoice_line_details ild on ild.iNVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
         JOIN platform.gold.v_markets m on m.market_key = ild.INVOICE_LINE_DETAILS_MARKET_KEY
         JOIN platform.gold.v_DATES dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
       --  JOIN platform.gold.v_companies c on ild.invoice_line_details_company_key = c.company_key ---***
     --    left join analytics.public.es_companies esc on esc.company_id = c.company_id and esc.owned ---****
where date_trunc(month, dd.date) between dateadd(month, -14, date_trunc(month, current_date)) and date_trunc(month, current_date)
  AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
--  AND esc.company_id IS  NULL ---****
group by date_trunc(month, dd.date),
         m.MARKET_ID,
         m.MARKET_NAME,
         m.market_type
),
monthly_market_goals as (
select mg.MARKET_ID,
       mg.NAME,
       mg.MONTHS::date as goal_month,
       mg.REVENUE_GOALS as revenue_goal
from ANALYTICS.PUBLIC.MARKET_GOALS mg
where MONTHS::date between dateadd(month, -14, date_trunc(month,current_date)) and date_trunc(month,current_date) AND mg.end_date IS NULL
)
select lsm.date,
             mmr.MARKET_ID,
             mmr.MARKET_NAME,
             mmr.rental_revenue,
             mmg.revenue_goal,
             mmr.rental_revenue/nullifzero(mmg.revenue_goal) as percent_of_goal,
             case when mmr.rental_revenue/nullifzero(mmg.revenue_goal) >= 0.9 and mmr.rental_revenue/nullifzero(mmg.revenue_goal) < 1 then 'Close to Goal'
                  when mmr.rental_revenue/nullifzero(mmg.revenue_goal) < 0.9 then 'Below Goal'
                  when mmr.rental_revenue/nullifzero(mmg.revenue_goal) >= 1 or mmg.revenue_goal = 0 then 'Above Goal'
             end as goal_met_type_flag,
            vmt.is_current_months_open_greater_than_twelve,
            mmr.market_type
from last_nine_months lsm
left join monthly_market_revenue mmr on mmr.MARKET_ID = lsm.MARKET_ID and mmr.revenue_month = lsm.date
left join monthly_market_goals mmg on mmg.MARKET_ID = lsm.MARKET_ID and mmg.goal_month = lsm.date
left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
              group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = lsm.market_id

;;
  }

  # dimension_group: date {
  #   label: ""
  #   type: time
  #   sql: ${TABLE}."DATE" ;;
  # }

  dimension: date {
    type: date_month
    sql: ${TABLE}."DATE" ;;
  }

  dimension: month_date {
    type: date
    label: "Month"
    sql: ${TABLE}."DATE" ;;
    html: {{ value | date: "%b %Y" }};;
  }



  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  dimension: revenue_goal {
    type: number
    sql: ${TABLE}."REVENUE_GOAL" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: is_current_months_open_greater_than_twelve {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  # dimension: percent_of_goal {
  #   type: number
  #   sql: ${TABLE}."PERCENT_OF_GOAL" ;;
  # }

  # dimension: goal_met_type_flag {
  #   type: string
  #   sql: ${TABLE}."GOAL_MET_TYPE_FLAG" ;;
  # }

  measure: total_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
  }

  # measure: total_revenue_goal_above {
  #   type: sum
  #   sql: ${rental_revenue} ;;
  #   filters: [goal_met_type_flag: "Above Goal"]
  #   value_format_name: usd_0
  # }

  # measure: total_revenue_goal_close {
  #   type: sum
  #   sql: ${rental_revenue} ;;
  #   filters: [goal_met_type_flag: "Close to Goal"]
  #   value_format_name: usd_0
  # }

  # measure: total_revenue_goal_below {
  #   type: sum
  #   sql: ${rental_revenue} ;;
  #   filters: [goal_met_type_flag: "Below Goal"]
  #   value_format_name: usd_0
  # }

  measure: total_market_goal {
    type: sum
    sql: ${revenue_goal} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"

  }

  measure: goal {
    type: sum

    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${revenue_goal} ;;
  }

  measure: rental_revenue_goal_met {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${goal} - ${total_revenue} <= 0 then ${total_revenue}
                 else null end;;
    }

  measure: rental_revenue_goal_unmet {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when  ${goal} - ${total_revenue} > 0 then ${total_revenue}
                 else null end;;
  }

  measure: rental_revenue_no_goal {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when SUM(${revenue_goal}) IS NULL then ${total_revenue}
      else null end ;;
  }

  measure: tot_rev_goal_above {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                 when ${total_revenue} > ${goal} THEN ${total_revenue}
                 when DIV0NULL(${total_revenue}, ${goal}) >= 1 then ${total_revenue}
                 else null end;;
  }

  measure: tot_rev_goal_close {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) >= 0.9 AND DIV0NULL(${total_revenue}, ${goal}) < 1 then ${total_revenue}
                 else null end;;
  }

  measure: tot_rev_goal_below {
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when SUM(${revenue_goal}) IS NULL then null
                  when ${total_revenue} > ${goal} THEN null
                 when  DIV0NULL(${total_revenue}, ${goal}) < 0.9 then ${total_revenue}
                 else null end;;
  }

  dimension: has_data {
    type: yesno
    sql: CASE WHEN ${revenue_goal} IS NULL AND ${total_revenue} IS NULL THEN FALSE ELSE TRUE END ;;
  }

  measure: remaining_to_goal {
    type: number
    value_format_name: usd_0
    sql: case when ${goal} - ${total_revenue} < 0 then null
      else ${goal} - ${total_revenue} end;;
    }
}