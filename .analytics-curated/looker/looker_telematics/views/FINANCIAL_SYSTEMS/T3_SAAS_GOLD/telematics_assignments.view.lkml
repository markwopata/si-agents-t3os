view: telematics_assignments {
  sql_table_name: "FINANCIAL_SYSTEMS"."T3_SAAS_GOLD"."TELEMATICS_ASSIGNMENTS" ;;

  dimension: ASSET_ID {
    type: string
    sql: ${TABLE}."FK_ASSET_ID" ;;
  }
  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: ASSIGNMENT_ID {
    type: string
    sql: ${TABLE}."PK_ASSIGNMENT_ID" ;;
  }
  dimension: DEACTIVATION_TICKET_ID {
    type: string
    sql: ${TABLE}."FK_DEACTIVATION_TICKET_ID" ;;
  }
  dimension: ASSET_NAME {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }
  dimension: DEVICE_SERIAL {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}."SERIAL_FORMATTED" ;;
  }
  dimension: DEVICE_TYPE {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }
  dimension: DEACTIVATION_TYPE {
    type: string
    sql: ${TABLE}."DEACTIVATION_TYPE" ;;
  }
  dimension: IN_SERIVCE_DATE {
    type: date
    sql: ${TABLE}."DATE_INSTALLED" ;;
  }
  dimension: END_SERVICE_DATE {
    type: date
    sql: ${TABLE}."DATE_UNINSTALLED" ;;
  }
  dimension: DEACTIVATION_DATE {
    type: date
    sql: ${TABLE}."DATE_DEACTIVATED" ;;
  }
}
