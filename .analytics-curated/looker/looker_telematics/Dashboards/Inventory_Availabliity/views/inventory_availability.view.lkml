view: inventory_availability {
  derived_table: {
    sql: select *
         from ANALYTICS.FISHBOWL_STAGING.INVENTORY_AVAILABILITY
         where reportdate in (select max(reportdate) from ANALYTICS.FISHBOWL_STAGING.INVENTORY_AVAILABILITY);;
  }
  #sql_table_name: "ANALYTICS"."FISHBOWL_STAGING"."INVENTORY_AVAILABILITY" ;;

  dimension: uomcode {
    type: string
    sql: ${TABLE}."UOMCODE" ;;
  }

  dimension: unavailableqty {
    label: "Unavailable Qty"
    type: number
    sql: ${TABLE}."UNAVAILABLE" ;;
  }

  dimension: onorderqty {
    type: number
    sql: ${TABLE}."ONORDER" ;;
  }

  dimension: committedqty {
    label: "Committed Qty"
    type: number
    sql: ${TABLE}."QTYCOMMITTED" ;;
  }

  dimension: notavailableqty {
    label: "Not Available to Pick Qty"
    type: number
    sql: ${TABLE}."TOTALNOTAVAILABLETOPICK" ;;
  }

  dimension: part {
    primary_key: yes
    type: string
    sql: ${TABLE}."PART" ;;
  }

  dimension: qty {
    label: "On Hand Qty"
    type: number
    sql: ${TABLE}."QTY" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: dropshipqty {
    label: "Dropship Qty"
    type: number
    sql: ${TABLE}."DROPSHIP" ;;
  }

  dimension: allocatedqty {
    label: "Allocated Qty"
    type:  number
    sql: ${TABLE}."ALLOCATED" ;;
  }

  dimension_group: reportdate {
    type: time
    timeframes: [date, week, month, time]
    sql: ${TABLE}."REPORTDATE" ;;
  }

  measure: totalqty {
    type: sum
    sql: ${qty} ;;
  }

  measure: totalonorderqty {
    label: "On Order Qty"
    type: sum
    sql: ${onorderqty} ;;
  }

}
