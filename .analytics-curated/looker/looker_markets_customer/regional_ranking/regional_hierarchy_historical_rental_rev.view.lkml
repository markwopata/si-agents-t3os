view: regional_hierarchy_historical_rental_rev {

 derived_table: {
  sql:
         select
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          TO_DATE(TO_VARCHAR(dd.year_month), 'YYYYMM') as date_month,
          sum(ild.invoice_line_details_amount) as rental_revenue,
          vmt.is_current_months_open_greater_than_twelve
      from
          platform.gold.v_line_items r
          JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
          JOIN platform.gold.v_markets m on m.market_key = ild.INVOICE_LINE_DETAILS_MARKET_KEY
          JOIN  platform.gold.v_dates  dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
          JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = m.market_id
           left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = m.market_id
      where
         r.LINE_ITEM_RENTAL_REVENUE = TRUE
          AND mrx.division_name = 'Equipment Rental'
          AND date_month >= '2023-01-01'
      group by
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end,
          vmt.is_current_months_open_greater_than_twelve,
          TO_DATE(TO_VARCHAR(dd.year_month), 'YYYYMM');;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: region_name {
  label: "Region"
  type: string
  sql: ${TABLE}."REGION_NAME" ;;
}

dimension: district {
  type: string
  sql: ${TABLE}."DISTRICT" ;;
}

dimension: market_name {
  label: "Market"
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
}

dimension: market_type {
  type: string
  sql: ${TABLE}."MARKET_TYPE" ;;
}

dimension: hard_down {
  type: yesno
  sql: ${TABLE}."HARD_DOWN" ;;
}

dimension: months_open_over_12 {
  type: yesno
  sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
}

dimension_group: date_month {
  type: time
  sql: ${TABLE}."DATE_MONTH" ;;
}

dimension: current_month {
  type: yesno
  sql: CASE WHEN ${date_month_date} = DATETRUNC(month, current_date) THEN TRUE ELSE FALSE END ;;
}

dimension: prior_month {
  type: yesno
  sql: CASE WHEN ${date_month_date} = DATETRUNC(month, DATEADD(month, '-1', current_date)) THEN TRUE ELSE FALSE END ;;
}

dimension: rental_revenue {
  type: number
  sql: ${TABLE}."RENTAL_REVENUE" ;;
}

 measure: rental_revenue_sum {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
  }

measure: current_month_total_rental_revenue {
  type: sum
  sql: ${rental_revenue} ;;
  filters: [current_month: "TRUE"]
  value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
}

measure: previous_month_total_rental_revenue {
  type: sum
  sql: ${rental_revenue} ;;
  filters: [prior_month: "TRUE"]
  value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
}

dimension: midwest_district {
  group_label: "Navigation Grouping"
  label: "View Region District Breakdowns"
  type: string
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1305?Region={{ region_name._rendered_value | url_encode }}&Market+Type=">
    {{rendered_value}} District Breakdown →</a></font></u></button>
     ;;

}

measure: industrial_district {
  group_label: "Navigation Grouping"
  label: "Industrial"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Industrial"]
}

measure: southwest_district {
  group_label: "Navigation Grouping"
  label: "Southwest"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Southwest"]
}

measure: mountain_west_district {
  group_label: "Navigation Grouping"
  label: "Mountain West"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Mountain West"]
}

measure: southeast_district {
  group_label: "Navigation Grouping"
  label: "Southeast"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Southeast"]
}

measure: pacific_district {
  group_label: "Navigation Grouping"
  label: "Pacific"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Pacific"]
}

measure: northeast_district {
  group_label: "Navigation Grouping"
  label: "Northeast"
  type: count_distinct
  sql: ${region_name} ;;
  html:
    <button style="background-color: #318CE7; border-radius: 5px; border: none; height: 30px; margin-bottom: 10px; margin-top: 5px;"><font color="#FAFAFA"><u><a href="#">District Breakdown →</a></font></u></button>
     ;;
  filters: [region_name: "Northeast"]
}

#     <thead>
#   <tr>
#     <th border: 10; padding: 10px 0;>
#     <font color="#0063f3"><u><a href="#">Midwest District Breakdown<img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a></font></u>

#     </th>
#   </tr>
# </thead>



set: detail {
  fields: [
    region_name,
    district,
    market_name,
    market_type,
    date_month_date,
    current_month,
    prior_month,
    rental_revenue
  ]
}
}