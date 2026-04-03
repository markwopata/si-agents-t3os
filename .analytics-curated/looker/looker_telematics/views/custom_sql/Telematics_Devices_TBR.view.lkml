view: Telematics_Devices_TBR {
  derived_table: {
    sql:
select *,
'TELE_01' as TBR_STATUS
from analytics.t3_saas_billing.telematics_accounting_trackers
union
select *,
'TELE_02' as TBR_STATUS
from analytics.t3_saas_billing.telematics_accounting_keypads_and_cameras
      ;;
  }

dimension: TBR_STATUS {
  type:  string
  sql: ${TABLE}.TBR_STATUS ;;
  }

dimension: SERIAL_NUM {
  type:  string
  sql:${TABLE}.SERIAL_NUM ;;
}

dimension: INV_LOG_ID {
  type: string
  sql: ${TABLE}.INV_LOG_ID ;;
}

dimension: PART_ID {
  type: string
  sql: ${TABLE}.PART_ID ;;
}

dimension: PART_DESCRIPTION {
  type: string
  sql: ${TABLE}.PART_DESCRIPTION ;;
}

dimension: STD_COST {
  type:  number
  sql: ${TABLE}.STD_COST ;;
}

dimension: CREATE_DATE {
  type:  date
  sql: ${TABLE}.CREATE_DATE ;;
}

dimension: EVENT_DATE {
  type:  date
  sql: ${TABLE}.EVENT_DATE ;;
}

dimension: RECORD_ID {
  type:  string
  sql: ${TABLE}.RECORD_ID ;;
}

dimension: SO_NUMBER {
  type:  string
  sql: ${TABLE}.SO_NUMBER ;;
}

dimension: CUSTOMER_ID {
  type:  string
  sql: ${TABLE}.CUSTOMER_ID ;;
}

dimension: QTY_CHG {
  type:  number
  sql: ${TABLE}.QTY_CHG ;;
}

dimension: QTY_CHG_TOTAL {
  type:  number
  sql: ${TABLE}.QTY_CHG_TOTAL ;;
}

dimension: COST_CHG {
  type:  number
  sql: ${TABLE}.COST_CHG ;;
}

dimension: COST_CHG_NT {
  type:  number
  sql: ${TABLE}.COST_CHG_NT ;;
}

dimension: SERIAL_FORMATTED {
  type:  string
  sql: ${TABLE}.SERIAL_FORMATTED ;;
}

dimension: TRACKER_COST {
  type:  number
  sql: ${TABLE}.TRACKER_COST ;;
}

dimension: NON_TRACKER_COST_PER_UNIT {
  type:  number
  sql: ${TABLE}.NON_TRACKER_COST_PER_UNIT ;;
}

dimension: TOTAL_COST {
  type:  number
  sql: ${TABLE}.TOTAL_COST ;;
}

dimension: SHIPPED {
  type:  date
  sql: ${TABLE}.SHIPPED ;;
}

dimension: FIRST_INSTALL {
  type:  date
  sql: ${TABLE}.FIRST_INSTALL ;;
}

dimension: CUST_GROUP {
  type:  string
  sql: ${TABLE}.CUST_GROUP ;;
}

dimension: CUST_NAME {
  type:  string
  sql: ${TABLE}.CUST_NAME ;;
}

dimension: DELIVERY_NAME {
  type:  string
  sql: ${TABLE}.DELIVERY_NAME ;;
}

dimension: SELL_PRICE {
  type:  number
  sql: ${TABLE}.SELL_PRICE ;;
}

dimension: SELL_COST {
  type:  number
  sql: ${TABLE}.SELL_COST ;;
}

dimension: SELL_PRICE_TOTAL_COST {
  type:  number
  sql: ${TABLE}.SELL_PRICE_TOTAL_COST ;;
}

dimension: SELL_COST_TOTAL_COST {
  type:  number
  sql: ${TABLE}.SELL_COST_TOTAL_COST ;;
}

dimension: SOURCE {
  type:  string
  sql: ${TABLE}.SOURCE ;;
}

}
