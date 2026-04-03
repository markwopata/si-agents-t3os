view: double_rented_assets {
  derived_table: {
    sql:
      select
        FK_ASSET_ID,
        RENTAL_A_ID,
        ORDER_A_ID,
        INVOICE_A_ID,
        INVOICE_A_NO,
        INVOICE_A_TIMESTAMP_INVOICE,
        RENTAL_A_DROPOFF_TIMESTAMP,
        RENTAL_A_RETURN_TIMESTAMP,
        RENTAL_B_ID,
        ORDER_B_ID,
        INVOICE_B_ID,
        INVOICE_B_NO,
        INVOICE_B_TIMESTAMP_INVOICE,
        IS_NEW_INVOICE_CREATED_WHILE_ASSET_STILL_OUT
      from financial_systems.auditing_gold.audit_asset_ids
      ;;
  }

  dimension: fk_asset_id {
    label: "Asset ID"
    type: number
    sql: ${TABLE}.FK_ASSET_ID ;;
    description: "Foreign key to the asset being evaluated."
  }

  dimension: rental_a_id {
    label: "First Rental ID"
    type: number
    sql: ${TABLE}.RENTAL_A_ID ;;
    description: "Rental id associated with the prior invoice for the asset."
  }

  dimension: order_a_id {
    label: "First Order ID"
    type: number
    sql: ${TABLE}.ORDER_A_ID ;;
    description: "Order id associated with rental_a_id derived from invoices."
  }

  dimension: invoice_a_id {
    type: number
    sql: ${TABLE}.INVOICE_A_ID ;;
    description: "Invoice id for the prior invoice containing the asset and rental."
  }

  dimension: invoice_a_no {
    label: "First Invoice Number"
    type: string
    sql: ${TABLE}.INVOICE_A_NO ;;
    description: "Invoice number for invoice_a_id."
  }

  dimension_group: invoice_a_timestamp_invoice {
    type: time
    sql: ${TABLE}.INVOICE_A_TIMESTAMP_INVOICE ;;
    description: "Invoice date for invoice_a_id from invoices timestamp_invoice."
  }

  dimension_group: rental_a_dropoff_timestamp {
    label: "First Rental Dropoff"
    type: time
    sql: ${TABLE}.RENTAL_A_DROPOFF_TIMESTAMP ;;
    description: "Delivery-derived start timestamp for rental_a_id from delivery types 1 and 3."
  }

  dimension_group: rental_a_return_timestamp {
    label: "First Rental Return"
    type: time
    sql: ${TABLE}.RENTAL_A_RETURN_TIMESTAMP ;;
    description: "Delivery-derived end timestamp for rental_a_id from delivery types 2, 4, and 6. Completed timestamp is preferred when present and date updated is used as fallback."
  }

  dimension: rental_b_id {
    label: "Second Rental ID"
    type: number
    sql: ${TABLE}.RENTAL_B_ID ;;
    description: "Rental id associated with the next invoice for the asset."
  }

  dimension: order_b_id {
    label: "Second Order ID"
    type: number
    sql: ${TABLE}.ORDER_B_ID ;;
    description: "Order id associated with rental_b_id derived from invoices."
  }

  dimension: invoice_b_id {
    type: number
    sql: ${TABLE}.INVOICE_B_ID ;;
    description: "Invoice id for the next invoice containing the asset and rental."
  }

  dimension: invoice_b_no {
    label: "Second Invoice Number"
    type: string
    sql: ${TABLE}.INVOICE_B_NO ;;
    description: "Invoice number for invoice_b_id."
  }

  dimension_group: invoice_b_timestamp_invoice {
    type: time
    sql: ${TABLE}.INVOICE_B_TIMESTAMP_INVOICE ;;
    description: "Invoice date for invoice_b_id from invoices timestamp_invoice."
  }

  dimension: is_new_invoice_created_while_asset_still_out {
    type: yesno
    sql: ${TABLE}.IS_NEW_INVOICE_CREATED_WHILE_ASSET_STILL_OUT ;;
    description: "True when invoice_b_timestamp_invoice occurs on or after rental_a_dropoff_ts and on or before rental_a_return_ts when present, indicating the asset was still out when the new invoice was created. Same order transitions are excluded."
  }
}
