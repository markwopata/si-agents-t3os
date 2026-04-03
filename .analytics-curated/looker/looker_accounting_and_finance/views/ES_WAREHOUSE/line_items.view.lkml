view: line_items {
  sql_table_name: public.line_items ;;
  drill_fields: [line_item_id]

  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."line_item_id" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."amount" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."asset_id" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."branch_id" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."date_created" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."date_updated" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."description" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."domain_id" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."extended_data" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."invoice_id" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."line_item_type_id" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."number_of_units" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."price_per_unit" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."rental_id" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."taxable" ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_id]
  }
}
