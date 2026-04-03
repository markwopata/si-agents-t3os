view: open_work_orders_monthly_report {
  sql_table_name: ANALYTICS.PARTS_INVENTORY.OPEN_WORK_ORDERS_MONTHLY_REPORT ;;

  dimension_group: run {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.run_time AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: report {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.report_month AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_owner {
    type: string
    sql: ${TABLE}.asset_owner ;;
  }
  dimension: asset_owner_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_owner_id ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }
  dimension: es_owned_or_maintained {
    type: yesno
    sql: ${TABLE}.ES_OWNED_OR_MAINTAINED ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: work_order_status {
    type: string
    sql: ${TABLE}.work_order_status ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}.invoice_number ;;
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ invoice_number._value }}</a> ;;
  }
  dimension: parts_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.parts_cost ;;
  }
  measure: total_parts_cost {
    type: sum
    value_format_name: usd_0
    sql: ${parts_cost} ;;
  }
  dimension: reg_hours {
    type: number
    sql: ${TABLE}.reg_hours ;;
  }
  dimension: ot_hours {
    type: number
    sql: ${TABLE}.ot_hours ;;
  }
  measure: total_hours {
    type: sum
    sql: (${reg_hours} + ${ot_hours}) ;;
  }
  dimension: wo_created {
    type: date
    convert_tz: no
    sql: ${TABLE}.wo_created ;;
  }
  dimension: wo_completed {
    type: date
    convert_tz: no
    sql: ${TABLE}.wo_completed ;;
  }
  dimension: billed_date {
    type: date
    convert_tz: no
    sql: ${TABLE}.billed_date ;;
  }
  dimension: last_interaction {
    type: date
    convert_tz: no
    sql: ${TABLE}.last_interaction ;;
  }
  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type ;;
  }
  dimension: es_owned {
    type: yesno
    sql: ${TABLE}.es_owned ;;
  }
  dimension: flex_50 {
    type: yesno
    sql: ${TABLE}.flex_50 ;;
  }
  dimension: flex_55 {
    type: yesno
    sql: ${TABLE}.flex_55 ;;
  }
  dimension: ad_max_prem {
    type: yesno
    sql: ${TABLE}.ad_max_prem ;;
  }
  dimension: crockett_partners_ii {
    type: yesno
    sql: ${TABLE}.crockett_partners_ii ;;
  }
  dimension: own_sale_pending_payment {
    type: yesno
    sql: ${TABLE}.own_sale_pending_payment ;;
  }
  dimension: own_equipment_fund_i {
    type: yesno
    sql: ${TABLE}.own_equipment_fund_i ;;
  }
  dimension: tech_average {
    type: number
    value_format_name: usd
    sql: ${TABLE}.tech_average ;;
  }
  measure: avg_tech_wage {
    type: average_distinct
    value_format_name: usd
    sql: ${tech_average}  ;;
  }
  measure: overtime_tech_wage {
    type: number
    value_format_name: usd
    sql: ${avg_tech_wage} * 1.5  ;;
  }
  dimension: blended_rate {
    type: number
    value_format_name: usd
    sql: ${TABLE}.blended_hourly_rate ;;
  }
  measure: blended_rate_with_overtime {
    type: average_distinct
    value_format_name: usd
    sql: ${blended_rate} ;;
  }
  measure: benfits_load {
    type: average_distinct
    value_format_name: percent_0
    sql: ${TABLE}.benifits_load ;;
  }
  measure: hourly_rate_used {
    type: number
    value_format_name: usd
    sql: (1 + ${benfits_load}) * ${blended_rate_with_overtime} ;;
  }
  measure: int_assets_weighted_warranty_hours {
    type: sum
    value_format_name: decimal_1
    filters: [es_owned_or_maintained: "yes", billing_type: "Warranty"]
    sql: (${reg_hours} + ${ot_hours}) * 0.41 * 0.8 ;;
  }
  measure: int_assets_weighted_customer_hours {
    type: sum
    value_format_name: decimal_1
    filters: [es_owned_or_maintained: "yes", billing_type: "Customer"]
    sql: (${reg_hours} + ${ot_hours}) * 0.73 * 0.8 ;;
  }
  measure: int_asset_est_externally_billed_hours_cost {
    type: number
    value_format_name: usd
    sql: (${int_assets_weighted_customer_hours} + ${int_assets_weighted_warranty_hours}) * ${hourly_rate_used} ;;
  }
  measure: int_assets_weighted_warranty_parts {
    type: sum
    value_format_name: usd
    filters: [es_owned_or_maintained: "yes", billing_type: "Warranty"]
    sql: (${parts_cost}) * 0.41 * 0.8 ;;
  }
  measure: int_assets_weighted_customer_parts {
    type: sum
    value_format_name: usd
    filters: [es_owned_or_maintained: "yes", billing_type: "Customer"]
    sql: (${parts_cost}) * 0.73 * 0.8 ;;
  }
  measure: int_asset_est_externally_billed_parts_cost {
    type: number
    value_format_name: usd
    sql: (${int_assets_weighted_customer_parts} + ${int_assets_weighted_warranty_parts});;
  }
  measure: int_asset_est_ext_billing {
    type: number
    value_format_name: usd
    sql: ${int_asset_est_externally_billed_hours_cost} + ${int_asset_est_externally_billed_parts_cost} ;;
  }
  measure: ext_assets_weighted_hours {
    type: sum
    value_format_name: decimal_1
    filters: [es_owned_or_maintained: "no"]
    sql: (${reg_hours} + ${ot_hours}) * 0.8 ;;
  }
  measure: ext_assets_weighted_parts {
    type: sum
    value_format_name: usd
    filters: [es_owned_or_maintained: "no"]
    sql: (${parts_cost}) * 0.8 ;;
  }
  measure: ext_asset_est_ext_billing {
    type: number
    value_format_name: usd
    sql: (${ext_assets_weighted_hours} * ${hourly_rate_used}) + ${ext_assets_weighted_parts} ;;
  }
  measure: accrual_total {
    type: number
    value_format_name: usd
    sql: ${ext_asset_est_ext_billing} + ${int_asset_est_ext_billing} ;;
  }
}
