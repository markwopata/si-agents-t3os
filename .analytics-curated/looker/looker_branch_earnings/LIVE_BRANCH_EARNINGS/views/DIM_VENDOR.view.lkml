view: DIM_VENDOR {
  sql_table_name: "BRANCH_EARNINGS"."DIM_VENDOR"
    ;;

  dimension: PK_VENDOR {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_VENDOR" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  dimension: VENDOR_CATEGORY {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: VENDOR_ID {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: VENDOR_NAME {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: VENDOR_SOURCE_KEY {
    type: number
    sql: ${TABLE}."VENDOR_SOURCE_KEY" ;;
  }

  dimension: VENDOR_STATUS {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension: VENDOR_TERM {
    type: string
    sql: ${TABLE}."VENDOR_TERM" ;;
  }

  dimension: VENDOR_TYPE {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF VENDORS"
    drill_fields: [VENDOR_CATEGORY, VENDOR_TYPE, VENDOR_STATUS, VENDOR_TERM, VENDOR_ID, VENDOR_NAME]
  }
}
