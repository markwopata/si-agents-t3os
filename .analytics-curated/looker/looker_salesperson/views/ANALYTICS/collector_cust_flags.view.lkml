view: collector_cust_flags {
  sql_table_name: "PUBLIC"."COLLECTOR_CUST_FLAGS"
    ;;

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: dnc {
    type: string
    sql: ${TABLE}."DNC" ;;
  }

  dimension: legal {
    type: string
    sql: ${TABLE}."LEGAL" ;;
  }

  dimension: sent_to_legal {
    type: yesno
    sql: ${legal} = 'LEGAL' ;;

  }

  dimension: oil {
    type: string
    sql: ${TABLE}."OIL" ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_name]
  }
}
