view: employee_commission_info {
  sql_table_name: "ANALYTICS"."COMMISSION"."EMPLOYEE_COMMISSION_INFO" ;;
  drill_fields: [employee_commission_info_id]

  dimension: employee_commission_info_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYEE_COMMISSION_INFO_ID" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }
  dimension: commission_end {
    type: date_raw
    sql: ${TABLE}."COMMISSION_END" ;;
  }
  dimension: commission_start {
    type: date_raw
    sql: ${TABLE}."COMMISSION_START" ;;
  }
  dimension: commission_type_id {
    type: number
    sql: ${TABLE}."COMMISSION_TYPE_ID" ;;
  }
  dimension: date_updated {
    type: date_raw
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: guarantee_amount {
    type: number
    sql: ${TABLE}."GUARANTEE_AMOUNT" ;;
  }
  dimension: guarantee_end {
    type: date_raw
    sql: ${TABLE}."GUARANTEE_END" ;;
  }
  dimension: guarantee_start {
    type: date_raw
    sql: ${TABLE}."GUARANTEE_START" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [employee_commission_info_id]
  }
}
