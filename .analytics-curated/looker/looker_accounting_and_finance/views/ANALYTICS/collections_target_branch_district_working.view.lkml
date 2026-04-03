view: collections_target_branch_district_working {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTIONS_TARGET_BRANCH_DISTRICT_WORKING" ;;

###### DIMENSIONS ######

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  ###### DATES ######

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension_group: qtr_quarters {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: CASE
    WHEN RIGHT(${TABLE}."QUARTER", 1) = '1' THEN CONCAT(LEFT(${TABLE}."QUARTER", 4), '-03-31')::date
    WHEN RIGHT(${TABLE}."QUARTER", 1) = '2' THEN CONCAT(LEFT(${TABLE}."QUARTER", 4), '-06-30')::date
    WHEN RIGHT(${TABLE}."QUARTER", 1) = '3' THEN CONCAT(LEFT(${TABLE}."QUARTER", 4), '-09-30')::date
    WHEN RIGHT(${TABLE}."QUARTER", 1) = '4' THEN CONCAT(LEFT(${TABLE}."QUARTER", 4), '-12-31')::date
    END ;;
  }

###### LINKS ######

  dimension: override_link {
    type: string
    sql: 'Link to Overrides' ;;
    html: <a href="https://docs.google.com/spreadsheets/d/1er7iz_Ym3gBHvroTxbCt8_z6sIFLRKntMhBlo2WxIsQ/edit#gid=0" target="_blank">Link to Overrides</a>  ;;
  }

###### MEASURES ######

  measure: collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS" ;;
  }
  measure: collections_day {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS_DAY" ;;
  }

  measure: current_ar {
    label: "Current A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR" ;;
  }

  measure: current_dso {
    label: "Current DSO"
    type: sum
    value_format_name: decimal_1
    sql: ${TABLE}."CURRENT_DSO" ;;
  }

  measure: final_revenue_growth_rate {
    type: average
    value_format_name: percent_1
    sql: ${TABLE}."FINAL_REVENUE_GROWTH_RATE" ;;
  }





  measure: past_due_ar {
    label: "Past Due A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAST_DUE_AR" ;;
  }

  measure: past_due_dso {
    label: "Past Due DSO"
    type: sum
    value_format_name: decimal_1
    sql: ${TABLE}."PAST_DUE_DSO" ;;
  }

  measure: prior_total_ar {
    label: "Prior Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PRIOR_TOTAL_AR" ;;
  }

  measure: projected_collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PROJECTED_COLLECTIONS" ;;
  }

  measure: projected_dso {
    label: "Projected DSO"
    type: sum
    value_format_name: decimal_1
    sql: ${TABLE}."PROJECTED_DSO" ;;
  }

  measure: projected_dso_override {
    label: "Projected DSO Override"
    type: average
    value_format_name: decimal_1
    sql: ${TABLE}."PROJECTED_DSO_OVERRIDE" ;;
  }

  measure: projected_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PROJECTED_REVENUE" ;;
  }

  measure: projected_total_ar {
    label: "Projected Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PROJECTED_TOTAL_AR" ;;
  }



  measure: revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: revenue_growth_rate {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."REVENUE_GROWTH_RATE" ;;
  }

  measure: total_ar_growth_rate {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."TOTAL_AR_GROWTH_RATE" ;;
  }

  measure: current_ar_growth_rate {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."CURRENT_AR_GROWTH_RATE" ;;
  }

  measure: past_due_ar_growth_rate {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}."PAST_DUE_AR_GROWTH_RATE" ;;
  }

  measure: revenue_growth_rate_override {
    type: average
    value_format_name: percent_1
    sql: ${TABLE}."REVENUE_GROWTH_RATE_OVERRIDE" ;;
  }

  measure: total_ar {
    label: "Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: total_dso {
    label: "Total DSO"
    type: sum
    value_format_name: decimal_1
    sql: ${TABLE}."TOTAL_DSO" ;;
  }

  ########## Calculations ##########

  measure: total_dso_calc {
    label: "Total DSO Calc"
    value_format_name: decimal_0
    type: number
    sql: iff(${revenue}=0,0, (${total_ar}/${revenue})*90) ;;
  }

  measure: current_dso_calc {
    label: "Current DSO Calc"
    value_format_name: decimal_0
    type: number
    sql: iff(${revenue}=0,0,(${current_ar}/${revenue})*90) ;;
  }

  measure: past_due_dso_calc {
    label: "Past Due DSO Calc"
    value_format_name: decimal_0
    type: number
    sql: iff(${revenue}=0,0,(${past_due_ar}/${revenue})*90) ;;
  }

  measure: projected_dso_calc {
    label: "Projected DSO Calc"
    value_format_name: decimal_0
    type: number
    sql: iff(${projected_revenue}=0,0,(${projected_total_ar}/${projected_revenue})*90) ;;
  }

  measure: total_ar_mm {
    label: "Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR"/1000000 ;;
  }

  measure: current_ar_mm {
    label: "Current A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR"/1000000 ;;
  }

  measure: past_due_ar_mm {
    label: "Past Due A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAST_DUE_AR"/1000000 ;;
  }

  measure: collections_mm {
    label: "Collections"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS"/1000000 ;;
  }

  measure: revenue_mm {
    label: "Revenue"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE"/1000000 ;;
  }

  measure: dso_70 {
    label: "Opportunity 70 DSO"
    type: number
    value_format_name: usd
    sql: iff(${total_dso_calc}>70,${total_ar_mm}-(70*(${revenue_mm}/90)),0)  ;;
  }

  measure: dso_60 {
    label: "Opportunity 60 DSO"
    type: number
    value_format_name: usd
    sql: iff(${total_dso_calc}>60,${total_ar_mm}-(60*(${revenue_mm}/90)),0)  ;;
  }










}
