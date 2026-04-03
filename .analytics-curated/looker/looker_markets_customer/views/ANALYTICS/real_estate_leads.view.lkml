view: real_estate_leads {
  sql_table_name: "JOTFORM"."REAL_ESTATE_LEADS"
    ;;
  drill_fields: [real_estate_leads_id]

  dimension: real_estate_leads_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."REAL_ESTATE_LEADS_ID" ;;
  }

  dimension: data {
    type: string
    sql: ${TABLE}."DATA" ;;
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

  dimension: form_id {
    type: number
    sql: ${TABLE}."FORM_ID" ;;
  }

  dimension: submission_id {
    type: number
    sql: ${TABLE}."SUBMISSION_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [real_estate_leads_id]
  }
}
