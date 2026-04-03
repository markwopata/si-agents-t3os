view: last_collector_comment {
  derived_table: {
    sql: WITH LASTNOTE as
(SELECT COMPANY_ID, MAX(DATE_CREATED) as DATE_CREATED
FROM "ES_WAREHOUSE"."PUBLIC"."COMPANY_NOTES"
WHERE USER_ID in (
SELECT DISTINCT u.USER_ID
FROM "ANALYTICS"."GS"."COLLECTOR_CUSTOMER_ASSIGNMENTS" cca
JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" u on upper(cca.FINAL_COLLECTOR) = upper(concat(u.FIRST_NAME,' ',u.LAST_NAME)))
GROUP BY COMPANY_ID
)

SELECT cn.COMPANY_ID, cn.DATE_CREATED, cn.NOTE_TEXT, CONCAT(u.FIRST_NAME,' ',u.LAST_NAME) as COLLECTOR_NAME
FROM "ES_WAREHOUSE"."PUBLIC"."COMPANY_NOTES" cn
JOIN LASTNOTE ln on ln.COMPANY_ID=cn.COMPANY_ID
JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" u on u.USER_ID = cn.USER_ID
WHERE cn.DATE_CREATED = ln.DATE_CREATED
 ;;
  }
  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: note_text {
    type: string
    sql: ${TABLE}."NOTE_TEXT" ;;
  }
  dimension: collector_name {
    type: string
    sql: ${TABLE}."COLLECTOR_NAME" ;;
  }
}
