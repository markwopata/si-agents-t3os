view: t3_revenue_support_data {
  derived_table: {
    sql: select * from
ANALYTICS.ACCOUNTING.T3_REVENUE_SUPPORT_ALL
                ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }
  dimension: rental_start_date {
    type: date
    sql: ${TABLE}.rental_start_date ;;
  }
  dimension: rental_end_date {
    type: date
    sql: ${TABLE}.rental_end_date ;;
  }
  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.billing_approved_date ;;
  }
  dimension: days_on_rent {
    type: number
    sql: ${TABLE}.days_on_rent ;;
  }
  dimension: tracker_installed_flag {
    type: string
    sql: ${TABLE}.tracker_installed_flag ;;
  }
  dimension: tracker_type {
    type: string
    sql: ${TABLE}.tracker_type ;;
  }
  dimension: invoice_amount {
    type: number
    sql: ${TABLE}.invoice_amount ;;
  }
  dimension: powered_unpowered {
    type: string
    sql: ${TABLE}.powered_unpowered ;;
  }
  dimension: tracker_charge_low {
    type: number
    sql: ${TABLE}.tracker_charge_low ;;
  }
  dimension: tracker_charge_high {
    type: number
    sql: ${TABLE}.tracker_charge_high ;;
  }
  dimension: billed_unbilled_flag {
    type: string
    sql: ${TABLE}.billed_unbilled_flag ;;
  }
  dimension: report_date {
    type: date
    sql: ${TABLE}.report_date ;;
  }
}
