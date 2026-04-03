view: ar_metrics_dashboard {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_METRICS_DASHBOARD" ;;


################# DIMENSIONS ########################
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }



################# DATES ########################
  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: quarter {
    type: date
    sql: case when ${month} in ('2022-10-31','2022-11-30','2022-12-31') then '2022-12-31'
              when ${month} in ('2023-01-31','2023-02-28','2023-03-31') then '2023-03-31'
              when ${month} in ('2023-04-30','2023-05-31','2023-06-30') then '2023-06-30'
              when ${month} in ('2023-07-31','2023-08-31','2023-09-30') then '2023-09-30' else '2099-12-31' end ;;
  }

################# MEASURES ########################

  measure: mtd_revenue {
    label: "MTD Revenue"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."MTD_REVENUE" ;;
  }

  measure: ttm_revenue {
    label: "TTM Revenue"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TTM_REVENUE" ;;
  }

  measure: current_ar {
    label: "Current A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR" ;;
  }

  measure: pd_ar {
    label: "Past Due A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PD_AR" ;;
  }

  measure: pd_ar_legal {
    label: "Past Due A/R Legal"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PD_AR_LEGAL" ;;
  }

  measure: pd_ar_non_legal {
    label: "Past Due A/R Other"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PD_AR_NON_LEGAL" ;;
  }

  measure: total_ar {
    label: "Total A/R"
    type: sum
   value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: toatl_dso {
    label: "Total DSO"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}."TOTAL_DSO" ;;
  }

  measure: current_dso {
    label: "Current DSO"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}."CURRENT_DSO" ;;
  }

  measure: pd_dso {
    label: "Past Due DSO"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}."PD_DSO" ;;
  }

  measure: collections {
    label: "Collections"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS" ;;
  }



  measure: collections_day {
    label: "Collections per Day"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS_DAY" ;;
  }

  measure: collections_qtr {
    label: "Collections per Day"
    type: number
    value_format_name: usd_0
    sql: ${collections}/91.25 ;;
  }

  measure: ttm_rev_growth  {
    label: "TTM Revenue Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TTM_REVENUE_GROWTH" ;;
  }

  measure: total_ar_growth  {
    label: "Total A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TOTAL_AR_GROWTH" ;;
  }

  measure: curr_ar_growth  {
    label: "Current A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."CURRENT_AR_GROWTH" ;;
  }

  measure: pd_ar_growth  {
    label: "Past Due A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."PD_AR_GROWTH" ;;
  }

  measure: total_ar_v_rev_growth {
    label: "Total A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TOTAL_AR_V_REV_GROWTH" ;;
  }

  measure: curr_ar_v_rev_growth {
    label: "Current A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."CURRENT_AR_V_REV_GROWTH" ;;
  }

  measure: pd_ar_v_rev_growth  {
    label: "Past Due A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."PD_AR_V_REV_GROWTH" ;;
  }

  measure: total_dso_change {
    label: "Total DSO Change"
    type: sum
    sql: ${TABLE}."TOTAL_DSO_CHANGE" ;;
  }

  measure: collections_growth  {
    label: "Collections Growth"
    type: sum
    sql: ${TABLE}."COLLECTIONS_GROWTH" ;;
  }


  measure: ttm_rev_growth_qtr  {
    label: "TTM Qtr Revenue Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TTM_REVENUE_GROWTH_QTR" ;;
  }

  measure: total_ar_growth_qtr  {
    label: "Total Qtr A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TOTAL_AR_GROWTH_QTR" ;;
  }

  measure: curr_ar_growth_qtr  {
    label: "Current Qtr A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."CURRENT_AR_GROWTH_QTR" ;;
  }

  measure: pd_ar_growth_qtr  {
    label: "Past Due Qtr A/R Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."PD_AR_GROWTH_QTR" ;;
  }

  measure: total_ar_v_rev_growth_qtr {
    label: "Total Qtr A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TOTAL_AR_V_REV_GROWTH_QTR" ;;
  }

  measure: curr_ar_v_rev_growth_qtr {
    label: "Current Qtr A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."CURRENT_AR_V_REV_GROWTH_QTR" ;;
  }

  measure: pd_ar_v_rev_growth_qtr  {
    label: "Past Due Qtr A/R vRev Growth"
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."PD_AR_V_REV_GROWTH_QTR" ;;
  }

################# LINK TO DETAILS ########################
  dimension: link_to_details {
    type: string
    html: {% if value == '9999' %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/988?Month={{ month._value | url_encode }}" target="_blank">Link to Details</a></font></u>
    {% else %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}" target="_blank">Link to Details</a></font></u>
    {% endif %};;
    sql: ${branch_id} ;;
  }

}
