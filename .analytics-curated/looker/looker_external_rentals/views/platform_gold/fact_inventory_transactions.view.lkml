view: fact_inventory_transactions {
  sql_table_name: "PLATFORM"."GOLD"."V_INVENTORY_TRANSACTIONS" ;;

  dimension: inventory_transaction_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_KEY" ;;
    hidden: yes
  }

  dimension: inventory_transaction_source {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_SOURCE" ;;
  }

  dimension: inventory_transaction_id {
    type: number
    sql: ${TABLE}."INVENTORY_TRANSACTION_ID" ;;
    value_format_name: id
  }

  dimension: inventory_transaction_flow {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_FLOW" ;;
  }

  dimension: inventory_transaction_company_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_COMPANY_KEY" ;;
    description: "FK to dim_companies"
  }

  dimension: inventory_transaction_rental_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_RENTAL_KEY" ;;
    description: "FK to dim_rentals"
  }

  dimension: inventory_transaction_part_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_PART_KEY" ;;
    description: "FK to dim_parts"
  }

  dimension: inventory_transaction_completed_date_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_COMPLETED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: inventory_transaction_invoice_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_INVOICE_KEY" ;;
    hidden: yes
  }

  dimension: inventory_transaction_work_order_key {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_WORK_ORDER_KEY" ;;
    hidden: yes
  }

  measure: inventory_transaction_item_quantity_received {
    type: number
    sql: ${TABLE}."INVENTORY_TRANSACTION_ITEM_QUANTITY_RECEIVED" ;;
    value_format_name: decimal_2
  }

  measure: inventory_transaction_item_cost_per_item {
    type: number
    sql: ${TABLE}."INVENTORY_TRANSACTION_ITEM_COST_PER_ITEM" ;;
    value_format_name: usd
  }

  dimension: inventory_transaction_recordtimestamp {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSACTION_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
