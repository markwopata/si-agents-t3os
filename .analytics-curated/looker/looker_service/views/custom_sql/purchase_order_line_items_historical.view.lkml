view: purchase_order_line_items_historical {
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;

  derived_table: {
    sql: select to_char(EMPLOYEE_ID) as employee_id
--, COALESCE(NICKNAME, FIRST_NAME || ' ' || LAST_NAME) full_name #HL taking out, causing duplicates.
, min(_es_update_timestamp) as start_date
, max(_es_update_timestamp) as end_date
from ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT
where YEAR(_es_update_timestamp) >= 2023
and EMPLOYEE_STATUS='Active'
AND DEFAULT_COST_CENTERS_FULL_PATH
LIKE ANY('Corp/Corp/Corporate/Supply Chain & Distribution%','E-Commerce/E-Commerce/E-Commerce/E-Commerce/E-Commerce') group by 1;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  # dimension: full_name {
  #   type: string
  #   sql: ${TABLE}."FULL_NAME" ;;
  # }
  dimension_group: start_date {
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
    sql: ${TABLE}."START_DATE" ;;
    }
  dimension_group: end_date {
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
    sql: ${TABLE}."END_DATE" ;;
    }
 }
