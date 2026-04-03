view: tele_03_non_serialized {
  sql_table_name: "FINANCIAL_SYSTEMS"."UR_TELEMATICS_GOLD"."TELE_03_NON_SERIALIZED" ;;

  dimension: INV_LOG_ID {
    type: string
    sql: ${TABLE}."INV_LOG_ID" ;;
  }
  dimension: PART_ID {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: PACKING_SLIP_ID {
    type: string
    sql: ${TABLE}."PACKING_SLIP_ID" ;;
  }
  dimension: SERIAL_NUM {
    type: string
    sql: ${TABLE}."SERIAL_NUM" ;;
  }
  dimension: PART_DESCRIPTION {
    type: string
    sql: ${TABLE}."PART_DESCRIPTION" ;;
  }
  dimension: SO_NUMBER {
    type: string
    sql: ${TABLE}."SO_NUMBER" ;;
  }
  dimension: CUST_GROUP {
    type: string
    sql: ${TABLE}."CUST_GROUP" ;;
  }
  dimension: CUST_NAME {
    type: string
    sql: ${TABLE}."CUST_NAME" ;;
  }
  dimension: DELIVERY_NAME {
    type: string
    sql: ${TABLE}."DELIVERY_NAME" ;;
  }
  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}."SERIAL_FORMATTED" ;;
  }
  dimension: SOURCE {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }
  dimension: STD_COST {
    type: number
    sql: ${TABLE}."STD_COST" ;;
  }
  dimension: QTY_CHG {
    type: number
    sql: ${TABLE}."QTY_CHG" ;;
  }
  dimension: TOTAL_QTY_CHG {
    type: number
    sql: ${TABLE}."TOTAL_QTY_CHG" ;;
  }
  dimension: COST_CHG {
    type: number
    sql: ${TABLE}."COST_CHG" ;;
  }
  dimension: COST_CHG_NT {
    type: number
    sql: ${TABLE}."COST_CHG_NT" ;;
  }
  dimension: TRACKER_COST {
    type: number
    sql: ${TABLE}."TRACKER_COST" ;;
  }
  dimension: NON_TRACKER_COST_PER_UNIT {
    type: number
    sql: ${TABLE}."NON_TRACKER_COST_PER_UNIT" ;;
  }
  dimension: TOTAL_COST {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }
  dimension: SELL_PRICE {
    type: number
    sql: ${TABLE}."SELL_PRICE" ;;
  }
  dimension: SELL_COST {
    type: number
    sql: ${TABLE}."SELL_COST" ;;
  }
  dimension: SELL_PRICE_TOTAL_COST {
    type: number
    sql: ${TABLE}."SELL_PRICE_TOTAL_COST" ;;
  }
  dimension: SELL_COST_TOTAL_COST {
    type: number
    sql: ${TABLE}."SELL_COST_TOTAL_COST" ;;
  }
  dimension: DATE_REQUESTED {
    type: date
    sql: ${TABLE}."DATE_REQUESTED" ;;
  }
  dimension: DATE_SHIPPED {
    type: date
    sql: ${TABLE}."DATE_SHIPPED" ;;
  }
  dimension: FIRST_INSTALL {
    type: string
    sql: ${TABLE}."FIRST_INSTALL" ;;
  }
}
