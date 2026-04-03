view: fin_ops_ar_summary {
  sql_table_name: "ANALYTICS"."TREASURY"."FIN_OPS_AR_SUMMARY" ;;

  ######### DIMENSIONS #########

  dimension: branch_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  ######### MEASURE #########

  measure: collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS"/1000000 ;;
  }

  measure: current_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR"/1000000 ;;
  }

  measure: past_due_ar {
    label: "Past Due A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAST_DUE_AR"/1000000 ;;
  }

  measure: prior_total_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PRIOR_TOTAL_AR"/1000000 ;;
  }


  measure: revenue {
    type:sum
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE_CALCULATED"/1000000 ;;
  }

  measure: total_ar {
    label: "Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR"/1000000 ;;
  }

  measure: collections_percent_rental_revenue {
    type: number
    value_format_name: percent_0
    sql: ${collections}/${revenue} ;;
  }

  measure: collections_per_day {
    type: number
    value_format_name: usd_0
    sql: ${collections}/90 ;;
  }

  measure: dso {
    type: number
    value_format_name: decimal_0
    sql: iff(${revenue}=0,0,(${total_ar}/${revenue})*90) ;;
  }

  measure: dso_70 {
    label: "Opportunity 70 DSO"
    type: number
    value_format_name: usd
    sql: iff(${dso}>70,${total_ar}-(70*(${revenue}/90)),0)  ;;
  }

  measure: dso_60 {
    label: "Opportunity 60 DSO"
    type: number
    value_format_name: usd
    sql: iff(${dso}>60,${total_ar}-(60*(${revenue}/90)),0)  ;;
  }




}
