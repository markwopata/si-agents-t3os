
view: current_month_oec_by_rep_company {
  derived_table: {
    sql: SELECT cmobrc.*,
    maobr.mtd_avg_oec,
    maobr.lmtd_avg_oec,
    maobr.diff_mtd,
    maobr.total_assets_on_rent_daily,
    maobr.total_oec_on_rent_daily,
    maobr.actively_renting_customers
    FROM analytics.bi_ops.current_month_oec_by_rep_company cmobrc
    LEFT JOIN analytics.bi_ops.mtd_avg_oec_by_rep maobr ON maobr.salesperson_user_id = cmobrc.salesperson_user_id
        ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: month_date {
    type: string
    sql: DATE_TRUNC('month', ${date_date}) ;;
  }

  dimension: salesperson_user_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: email_address {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: home_market {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."HOME_MARKET" ;;
  }

  dimension: rep {
    group_label: "Sales Rep Info"
    label: "Rep - Market"
    sql: concat(${name}, ' - ', ${home_market}) ;;
  }

  dimension: home_market_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."HOME_MARKET_ID" ;;
  }

  dimension: district {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: employee_title {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }


  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  measure: company_id_count{
    type: count_distinct
    sql:${company_id} ;;
    drill_fields:[actively_renting_drill*]

  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_max {
    type: max
    label: "Assets On Rent Max"
    sql: ${assets_on_rent} ;;
  }

  measure: assets_on_rent_sum {
    type: sum
    label: "Current Assets On Rent"
    sql: ${assets_on_rent} ;;
    drill_fields: [actively_renting_drill*]
    }

  measure: assets_on_rent_avg {
    type: average
    label: "Avg Assets On Rent MTD"
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_1
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
    label: "OEC On Rent"
  }

  measure: oec_on_rent_max{
    type: max
    label: "OEC On Rent"
    sql:  ${oec_on_rent};;

    value_format_name: usd_0
  }

  measure: avg_oec_day {
    type: number
    sql: ROUND(DIV0NULL(SUM(${oec_on_rent}),COUNT(${oec_on_rent})), 2) ;;
    value_format_name: usd_0
  }

  measure: total_oec {
    type: sum
    sql: ${oec_on_rent};;
    label: "Current OEC On Rent"
    drill_fields: [oec_on_rent_drill*]
    value_format_name: usd_0
  }



  measure: avg_oec_month {
    type: number
    sql:ROUND(DIV0NULL(${total_oec}, COUNT(DISTINCT ${date_date})), 2) ;;
    drill_fields: [avg_oec_companies_drill*]
    value_format_name: usd_0
    label: "Avg OEC MTD"
  }

  dimension: mtd_avg_oec {
    group_label: "MTD OEC Group"
    type: number
    sql: ${TABLE}."MTD_AVG_OEC" ;;
  }
  dimension: lmtd_avg_oec {
    group_label: "MTD OEC Group"
    type: number
    sql: ${TABLE}."LMTD_AVG_OEC" ;;
  }
  dimension: diff_mtd {
    group_label: "MTD OEC Group"
    type: number
    sql: ${TABLE}."DIFF_MTD" ;;
  }

  measure: mtd_avg_oec_max {
    group_label: "MTD OEC Group"
    type: max
    sql:${mtd_avg_oec} ;;
    value_format_name: usd_0
    drill_fields: [avg_oec_companies_drill*]
    label: "Avg OEC MTD"
  }
  measure: lmtd_avg_oec_max {
    group_label: "MTD OEC Group"
    type: max
    sql:${lmtd_avg_oec} ;;
    value_format_name: usd_0
  }
  measure: diff_mtd_max {
    group_label: "MTD OEC Group"
    type: max
    sql:${diff_mtd} ;;
    value_format_name: usd_0
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font>
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font>
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %}
    ;;
  }


  measure: total_assets_on_rent_daily {
    group_label: "MTD OEC Group"
    type: max
    sql:${TABLE}."TOTAL_ASSETS_ON_RENT_DAILY" ;;
    value_format_name: decimal_0
  }
  measure: total_oec_on_rent_daily {
    group_label: "MTD OEC Group"
    type: max
    sql:${TABLE}."TOTAL_OEC_ON_RENT_DAILY" ;;
    description: "Current Date OEC on Rent"
    value_format_name: usd_0
  }
  measure: actively_renting_customers {
    group_label: "MTD OEC Group"
    type: max
    sql:${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
    value_format_name: decimal_0
  }


  dimension: one_flag {
    type:  number
    sql:${TABLE}."ONE_FLAG" ;;
  }

  set: oec_on_rent_drill {
    fields: [company_name, total_oec, assets_on_rent_sum]
  }

  set: actively_renting_drill {
    fields: [company_name, total_oec, assets_on_rent_sum]
  }

  set: avg_oec_companies_drill {
    fields: [company_name, avg_oec_month, assets_on_rent_avg]
  }

  set: detail {
    fields: [

  salesperson_user_id,
  company_name,
  company_id,
  assets_on_rent_max,
  avg_oec_month
    ]
  }
}
