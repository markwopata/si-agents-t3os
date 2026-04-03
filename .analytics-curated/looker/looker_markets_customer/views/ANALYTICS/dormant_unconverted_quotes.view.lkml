view: dormant_unconverted_quotes {
  sql_table_name: "ANALYTICS"."BI_OPS"."DORMANT_UNCONVERTED_QUOTES" ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension_group: last_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_MODIFIED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }
  dimension: quote_id {
    type: string
    sql: ${TABLE}."QUOTE_ID" ;;
  }
  dimension: quote_number {
    type: string
    sql: ${TABLE}."QUOTE_NUMBER" ;;
    html:
    <font color="#0063f3"><a href="https://quotes.estrack.com/{{quote_id._rendered_value}}"target="_blank"><b>{{ rendered_value }} ➔</b>
 ;;
value_format: "0"
  }
  dimension: rental_subtotal {
    type: number
    sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
    value_format_name: usd_0
  }
  dimension: sp_name {
    label: "Sales Rep"
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [equipment_class_name]
  }
}
