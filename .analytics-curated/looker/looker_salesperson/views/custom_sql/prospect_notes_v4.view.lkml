view: prospects_notes_v4 {
  derived_table: {
    sql: SELECT N.*, M.COMPANY_NAME
from ANALYTICS.WEBAPPS.CRM__PROSPECTS__NOTES__V4 AS N
LEFT JOIN ANALYTICS.WEBAPPS.CRM__PROSPECTS__MAPPING__V4 AS M
ON N.PROSPECT_ID = M.PROSPECT_ID  ;;
  }



  dimension: note_id {
    type: number
    sql: ${TABLE}.NOTE_ID ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.TIMESTAMP ;;
  }

  dimension: prospect_id {
    type: string
    sql: ${TABLE}.PROSPECT_ID ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.NOTE ;;
  }

  dimension: note_created_by {
    type: string
    sql: ${TABLE}.SALES_REPRESENTATIVE_EMAIL_ADDRESS ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: note_type {
    type: string
    sql: ${TABLE}.NOTE_TYPE ;;
  }
  }
