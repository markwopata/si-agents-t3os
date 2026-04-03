view: high_level_financials {
  derived_table: {
    sql:
    select * from analytics.public.high_level_financials_snap
  ;;
  }


  measure: oec_avg {
    type: sum
    value_format: "#,##0;-#,##0;-"
    sql: ${TABLE}."OEC_AVG" ;;
  }

  measure: oec_sum {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: rent_rev_sum {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."RENT_REV" ;;
  }

  measure: del_rev_sum {
    type: sum
    sql: ${TABLE}."DEL_REV" ;;
  }

  measure: total_rev_sum {
    type: sum
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  measure: pd_del_rev_sum {
    type: sum
    sql: ${TABLE}."PD_DEL_REV" ;;
  }

  measure: del_exp_sum {
    type: sum
    sql: ${TABLE}."DEL_EXP" ;;
  }

  measure: comp_sum {
    type: sum
    sql: ${TABLE}."COMP" ;;
  }

  measure: wages_sum {
    type: sum
    sql: ${TABLE}."WAGES" ;;
  }

  measure: overtime_sum {
    type: sum
    sql: ${TABLE}."OVERTIME" ;;
  }

  measure: hauling_sum {
    type: sum
    sql: ${TABLE}."HAULING" ;;
  }

  measure: rent_to_oec {
    label: "Rent Revenue Percent of OEC"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when ${oec_sum} = 0 then 0 else ${rent_rev_sum} / ${oec_sum} end;;
  }

  measure: del_to_rev {
    label: "Delivery Gross Revenue Percent of Rent Revenue"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rent_rev_sum} = 0 then 0 else ${del_rev_sum} / ${rent_rev_sum} end;;
  }

  measure: hauling_to_rev {
    label: "Outside Hauling Percent of Rent Revenue"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rent_rev_sum} = 0 then 0 else ${hauling_sum} / ${rent_rev_sum} end;;
  }

  measure: labor_to_rev {
    label: "Total Labor Percent of Rent Revenue"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${rent_rev_sum} = 0 then 0 else ${comp_sum} / ${rent_rev_sum} end ;;
  }

  measure: ot_to_rev {
    label: "Overtime Percent of Total Labor"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${wages_sum} = 0 then 0 else ${overtime_sum} / ${wages_sum} end ;;
  }

  measure: delivery_recovery {
    label: "Delivery Recovery Percent"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: case when ${del_exp_sum} = 0 then 0 else ${pd_del_rev_sum} / ${del_exp_sum} end  ;;
  }

  measure: net_income  {
    label: "Net Income"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:  ${TABLE}."NET_INCOME" ;;
  }

  dimension: cleaned_rank {
    # label: "Current Rank"
    type: string
    sql: iff(${TABLE}."MONTH_RANK" = 0,null,${TABLE}."MONTH_RANK")::varchar ;;
  }

  dimension: current_month_rank {
    label: "Current Rank"
    type: string
    sql: ${cleaned_rank} ;;
  }

  # measure: last_month_rank {
  #   label: "Last Month Rank"
  #   type: number
  #   sql:  ;;
  # }

  dimension: mkt_id {
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: mkt_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
  }





  dimension: months_open_old {
    type: number
    sql:  ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: oec {
    type: number
    # link: {
    #   label: "Detail View"
    #   url: "https://equipmentshare.looker.com/dashboards/531?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ filterable_value }}&Markets+Greater+Than+12+Months+Open={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    # }
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rent_rev {
    type: number
    sql: ${TABLE}."RENT_REV" ;;
  }

  dimension: comp {
    type: number
    sql: ${TABLE}."COMP" ;;
  }

  dimension: wages {
    type: number
    sql: ${TABLE}."WAGES" ;;
  }

  dimension: overtime {
    type: number
    sql: ${TABLE}."OVERTIME" ;;
  }

  dimension: hauling {
    type: number
    sql: ${TABLE}."HAULING" ;;
  }


  measure: financial_utilization {
    label: "Financial Utilization %"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${rent_to_oec} * 12 ;;
  }



  measure: unavailable_oec_percent {
    label: "Unavailable OEC %"
    type: average
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${TABLE}."UNAVAILABLE_OEC_PERCENT" ;;
  }

  measure: percent_discount_average {
    label: "Average Discount"
    type: average
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${TABLE}."AVERAGE_DISCOUNT" ;;
  }

  dimension: employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }



  # drill_fields: [hr_greenhouse_link.greenhouse_link]


  dimension: gm_personal_email {
    label: "General Manager Personal Email"
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension: gm_work_email {
    label: "General Manager Work Email"
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }



  measure: unassigned_hours {
    type: average
    #value_format: "#,##0.00;(#,##0.00);-"
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${TABLE}."UNASSIGNED_HOURS"  ;;
  }

  measure: equipment_sale_rev {
    label: "Sales Revenue"
    type: sum
    sql: ${TABLE}."SALE_REV" ;;
  }

  measure: equipment_sale_exp {
    label: "Cost of Sales Revenue"
    type: sum
    sql: ${TABLE}."SALE_EXP" ;;
  }



  measure: net_income_pct_total_revenue {
    label: "Net Income % of Total Revenue"
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql:  case when sum(${TABLE}."TOTAL_REV") = 0 then 0 else sum(${TABLE}."NET_INCOME") / sum(${TABLE}."TOTAL_REV") end ;;
  }



}
