view: missing_rate_assignments {
  sql_table_name: "PUBLIC"."MISSING_RATE_ASSIGNMENTS"
    ;;

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension_group: first_rental {
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
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }

  dimension: invoice_ct {
    type: number
    sql: ${TABLE}."INVOICE_CT" ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
