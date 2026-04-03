view: cust_collector_notes {
  derived_table: {
    sql:
    WITH collector_notes AS (
      SELECT
        TO_CHAR(NOTES.COMPANY_ID)                                             AS CUSTOMER_ID,
        COMPANIES.NAME                                                        AS CUSTOMER,
        NOTES.COMPANY_NOTE_ID                                                 AS NOTE_ID,
        NOTES.NOTE_TEXT                                                       AS NOTE_TEXT,
        CONVERT_TIMEZONE('America/Chicago', NOTES.DATE_CREATED)               AS DATETIME,
        CAST(CONVERT_TIMEZONE('America/Chicago', NOTES.DATE_CREATED) AS DATE) AS DATE,
        CAST(CONVERT_TIMEZONE('America/Chicago', NOTES.DATE_CREATED) AS TIME) AS TIME,
        NOTES.USER_ID                                                         AS USER_ID
      FROM ES_WAREHOUSE.PUBLIC.COMPANY_NOTES NOTES
      LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES
        ON NOTES.COMPANY_ID = COMPANIES.COMPANY_ID
      WHERE NOTES.NOTE_TYPE_ID = 3
        AND NOTES.USER_ID IN (SELECT USER_ID FROM ANALYTICS.BI_OPS.COLLECTORS)
    )
    , notes_days AS (
      SELECT DISTINCT date
      FROM collector_notes
    )
    , collectors AS (
      SELECT
        USERS.USER_ID                                                         AS USER_ID,
        USERS.EMAIL_ADDRESS                                                   AS USER_EMAIL,
        CONCAT(
          COALESCE(USERS.FIRST_NAME, ''), ' ',
          COALESCE(USERS.MIDDLE_NAME, ''),
          IFF(USERS.MIDDLE_NAME IS NULL OR TRIM(USERS.MIDDLE_NAME) = '', '', ' '),
          COALESCE(USERS.LAST_NAME, '')
        )                                                                     AS FULL_NAME,
        SPLIT_PART(CD.DIRECT_MANAGER_NAME, ' (', 1)                           AS USER_MANAGER,
        COLLECTORS.START_DATE                                                 AS START_DATE,
        COLLECTORS.END_DATE                                                   AS END_DATE
      FROM ES_WAREHOUSE.PUBLIC.USERS
      JOIN (
        SELECT USER_ID, MAX(START_DATE) AS START_DATE, MIN(END_DATE) AS END_DATE
        FROM ANALYTICS.BI_OPS.COLLECTORS
        GROUP BY USER_ID
      ) COLLECTORS
        ON USERS.USER_ID = COLLECTORS.USER_ID
      LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY CD
        ON LOWER(USERS.EMAIL_ADDRESS) = LOWER(CD.WORK_EMAIL)
    )
    SELECT
      d.date,
      c.user_id,
      c.user_email,
      c.full_name,
      c.user_manager,
      n.customer_id,
      n.customer,
      n.note_id,
      n.note_text,
      n.time,
      IFF(n.user_id IS NOT NULL, 1, 0) AS note_count
    FROM collectors c
    JOIN notes_days d ON d.date BETWEEN c.start_date AND c.end_date
    LEFT JOIN collector_notes n
      ON d.date = n.date AND c.user_id = n.user_id
    ;;
  }

  measure: customer_count { type: count_distinct sql: ${customer_id} ;; drill_fields: [customer_count_drill*] }
  measure: note_count     { type: sum            sql: ${TABLE}."NOTE_COUNT" ;; drill_fields: [note_count_drill*] }

  measure: count {
    type: count
  }

  dimension: user_email { type: string sql: ${TABLE}."USER_EMAIL" ;; }

  dimension: customer_id  { type: string sql: ${TABLE}."CUSTOMER_ID" ;; }
  dimension: customer     { type: string sql: ${TABLE}."CUSTOMER" ;; }
  dimension: note_id      { type: string sql: ${TABLE}."NOTE_ID" ;; }
  dimension: note_text    { type: string sql: ${TABLE}."NOTE_TEXT" ;; }
  dimension: date         { convert_tz: no type: date             sql: ${TABLE}."DATE" ;; }
  dimension: time         { convert_tz: no type: date_time_of_day sql: ${TABLE}."TIME" ;; }

  dimension_group: period {
    convert_tz: no
    type: time
    view_label: "Period"
    timeframes: [date, month, month_name, month_num, quarter, year]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: user_id      { type: string sql: ${TABLE}."USER_ID" ;; }
  # dimension: user_name  { type: string sql: ${TABLE}."USER_NAME" ;; }  # REMOVE or add column to SQL

  dimension: full_name    { type: string sql: ${TABLE}."FULL_NAME" ;; }
  dimension: user_manager { type: string sql: ${TABLE}."USER_MANAGER" ;; }

  set: customer_count_drill { fields: [customer, note_count] }
  set: note_count_drill     { fields: [date, time, full_name, note_text] }
}
