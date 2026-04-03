view: company_region {
  sql_table_name: "ANALYTICS"."PUBLIC"."COMPANY_REGION"
    ;;
  drill_fields: [company_region_id]

  dimension: company_region_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_REGION_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_region_id]
  }
}
