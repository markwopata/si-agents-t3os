view: project_notes {
  derived_table: {
    sql: SELECT PM.PROJECT_ID AS PROJECT_ID, PN.NOTE_TYPE, PM.PROJECT_NAME AS PROJECT_NAME,
PN.SALES_REPRESENTATIVE_EMAIL_ADDRESS AS NOTE_CREATED_BY, PN.TIMESTAMP AS TIMESTAMP,
PN.NOTE AS NOTE
FROM  ANALYTICS.WEBAPPS.CRM__PROJECT__NOTES__V4 AS PN
INNER JOIN ANALYTICS.WEBAPPS.CRM__PROJECT__MAPPING__V4 AS PM
ON PN.PROJECT_ID = PM.PROJECT_ID::VARCHAR  ;;
  }


  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.TIMESTAMP ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.PROJECT_ID ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.NOTE ;;
  }

  dimension: note_created_by {
    type: string
    sql: ${TABLE}.NOTE_CREATED_BY ;;
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.PROJECT_NAME ;;
  }

  dimension: note_type {
    type: string
    sql: ${TABLE}.NOTE_TYPE ;;
  }
}
