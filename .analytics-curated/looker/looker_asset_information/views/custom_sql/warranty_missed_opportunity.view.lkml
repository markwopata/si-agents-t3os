view: warranty_missed_opportunity {
 sql_table_name: "ANALYTICS"."WARRANTIES"."NEW_MISSED_WARRANTY_OPPORTUNITY_TMP" ;;

  dimension: likely_missed_opportunity {
    type: yesno
    sql: ${TABLE}.likely_missed_opportunity;;
  }

  dimension: reviewed {
    type: yesno
    sql: ${TABLE}.reviewed ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}.originator ;;
  }

  dimension: date_completed {
    type: date
    sql: ${TABLE}.date_completed ;;
  }

  dimension: wo_date_billed {
    type: date
    sql: ${TABLE}.wo_date_billed ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_no._value }}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
  }

  dimension: internal_billing {
    type: yesno
    sql: ${TABLE}.internal_billing ;;
  }

  dimension: warranty_billing {
    type: yesno
    sql: ${TABLE}.warranty_billing ;;
  }

  dimension: billing_date {
    type: date
    sql: ${TABLE}.billing_date ;;
  }

  dimension: billed_company {
    type: string
    sql: ${TABLE}.billed_company ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type ;;
  }

  dimension: wo_description {
    type: string
    sql: ${TABLE}.wo_description ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: asset_year {
    type: number
    value_format_name: id
    sql: ${TABLE}.year ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}.hours_at_service ;;
  }

  dimension: warranties {
    type: string
    sql: ${TABLE}.warranties ;;
  }

  dimension: warranties_description {
    type: string
    sql: ${TABLE}.warranties_description ;;
  }

  dimension: warrantable_parts_used {
    type: yesno
    sql: ${TABLE}.warrantable_parts_used ;;
  }

  dimension: warrantable_parts {
    type: number
    sql: ${TABLE}.warrantable_parts ;;
  }

  dimension: parts {
    type: string
    sql: ${TABLE}.parts ;;
  }

  dimension: part_descriptions {
    type: string
    sql: ${TABLE}.parts_descriptions ;;
  }

  dimension: warrantable_parts_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warrantable_part_cost ;;
  }

  dimension: estimated_labor {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.estimated_labor;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_cost ;;
  }

  dimension: last_tech_entry {
    type: date
    sql: ${TABLE}.last_tech_entry ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }
}
