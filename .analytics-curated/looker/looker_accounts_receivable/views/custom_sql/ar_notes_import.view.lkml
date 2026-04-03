#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: ar_notes_import {
  derived_table: {
    sql: SELECT
          'Customer'                                                                    AS TYPE,
          TO_CHAR(NOTES.COMPANY_ID)                                                     AS ERP_ID,
          CONCAT(USER.FIRST_NAME, ' ', USER.LAST_NAME, ' - ', NOTES.NOTE_TEXT)          AS TEXT,
          CAST(CONVERT_TIMEZONE('America/Chicago', NOTES.DATE_CREATED) AS DATE)         AS DATE,
          NOTES.COMPANY_NOTE_ID                                                         AS ADMIN_NOTE_ID,
          CAST(CONVERT_TIMEZONE('America/Chicago', NOTES._ES_UPDATE_TIMESTAMP) AS DATE) AS ADMIN_TABLE_DATE
      FROM
          ES_WAREHOUSE.PUBLIC.COMPANY_NOTES NOTES
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS USER ON NOTES.USER_ID = USER.USER_ID
              JOIN ANALYTICS.INTACCT.CUSTOMER INT_CUST ON TO_CHAR(NOTES.COMPANY_ID) = INT_CUST.CUSTOMERID
      WHERE
            NOTES.NOTE_TYPE_ID = 1
      --  AND NOTES.COMPANY_NOTE_ID >= 734789
      --   AND OTHER_DATE BETWEEN '2023-05-01' AND '2023-08-31'
      ORDER BY
          NOTES.COMPANY_NOTE_ID ASC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: erp_id {
    type: string
    sql: ${TABLE}."ERP_ID" ;;
  }

  dimension: text {
    type: string
    sql: ${TABLE}."TEXT" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: admin_note_id {
    type: number
    sql: ${TABLE}."ADMIN_NOTE_ID" ;;
  }

  dimension: admin_table_date {
    type: date
    sql: ${TABLE}."ADMIN_TABLE_DATE" ;;
  }

  set: detail {
    fields: [
        type,
	erp_id,
	text,
	date,
	admin_note_id,
	admin_table_date
    ]
  }
}
