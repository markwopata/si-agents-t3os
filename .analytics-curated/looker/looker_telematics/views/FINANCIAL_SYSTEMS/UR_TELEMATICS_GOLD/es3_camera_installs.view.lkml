view: es3_camera_installs {
  sql_table_name: "FINANCIAL_SYSTEMS"."UR_TELEMATICS_GOLD"."ES3_CAMERA_INSTALLS" ;;

  dimension: CAMERA_ID {
    type: string
    sql: ${TABLE}."CAMERA_ID" ;;
  }
  dimension: SERIAL_NUMBER {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}."SERIAL_FORMATTED" ;;
  }
  dimension: _01_FIRST_INSTALL {
    type: string
    sql: ${TABLE}."_01_FIRST_INSTALL" ;;
  }
  dimension: _03_UNINSTALL_PLUS12 {
    type: string
    sql: ${TABLE}."_03_UNINSTALL_PLUS12" ;;
  }
  dimension: ESTIMATED_COST {
    type: number
    sql: ${TABLE}."ESTIMATED_COST" ;;
  }
  dimension: FIRST_INSTALL {
    type: date
    sql: ${TABLE}."FIRST_INSTALL" ;;
  }
  dimension: UNINSTALLED {
    type: date
    sql: ${TABLE}."UNINSTALLED" ;;
  }
}
