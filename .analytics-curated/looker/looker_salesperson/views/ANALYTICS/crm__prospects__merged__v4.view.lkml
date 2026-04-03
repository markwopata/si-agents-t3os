view: crm__prospects__merged__v4 {
  sql_table_name: "ANALYTICS"."WEBAPPS"."CRM__PROSPECTS__MERGED__V4"
    ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: merge_id {
    type: number
    sql: ${TABLE}."MERGE_ID" ;;
  }

  dimension: prospect_id {
    type: string
    sql: ${TABLE}."PROSPECT_ID" ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}."SALES_REPRESENTATIVE_EMAIL_ADDRESS" ;;
  }

  dimension_group: timestamp {
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
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
