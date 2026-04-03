view: gold_vendor_reimbursements_accrual_summary {
  sql_table_name: "ANALYTICS"."REIMBURSEMENTS"."GOLD_VENDOR_REIMBURSEMENTS_ACCRUAL_SUMMARY" ;;

################# DIMENSIONS #################

  dimension: vendor_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: vendor_name {
    type:  string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: order_number_grouped {
    type: string
    sql: ${TABLE}."ORDER_NUMBER_GROUPED" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: order_status  {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: equipment_make {
    type: string
    sql: ${TABLE}."EQUIPMENT_MAKE" ;;
  }

  dimension: equipment_model  {
    type: string
    sql: ${TABLE}."EQUIPMENT_MODEL" ;;
  }

  dimension: model_year {
    type: number
    value_format_name: id
    sql: ${TABLE}."MODEL_YEAR" ;;
  }

  dimension: owner_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."OWNER_ID" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: rule_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RULE_ID" ;;
  }

  dimension: rule_year {
    type: number
    value_format_name: id
    sql: ${TABLE}."RULE_YEAR" ;;
  }

  dimension: rule {
    type: string
    sql: ${TABLE}."RULE" ;;
  }

  dimension_group: invoice {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension_group: release {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RELEASE_DATE" ;;
  }

  dimension_group: po_approved {
    type: time
    convert_tz: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PO_APPROVED_DATE" ;;
  }

  dimension: reimbursement_rate {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}."REIMBURSEMENT_RATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }

  dimension: serial_vin {
    label: "Serial_VIN"
    type: string
    sql: ${TABLE}."SERIAL_VIN" ;;
  }

  dimension: reimbursement_amount_dim {
    value_format_name: usd
    type: number
    sql: ${TABLE}."REIMBURSEMENT_AMOUNT" ;;
  }



  ################# MEASURES #################

  measure: reimbursement_amount {
    type: sum
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}."REIMBURSEMENT_AMOUNT" ;;
    filters: [reimbursement_amount_dim:"<>0"]
  }

  measure: net_price {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."NET_PRICE" ;;
  }

  measure: total_oec {
    label: "Total OEC"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  measure: oec_less_tax {
    label: "OEC Less Tax"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."OEC_LESS_TAX" ;;
  }

################# DRILL FIELDS #################

  set: trx_details {
    fields: [vendor_name,vendor_id,order_number,order_number_grouped,asset_id,serial_vin,invoice_number,invoice_date,release_date,po_approved_date,
      order_status,finance_status,equipment_make,equipment_model,model_year,factory_build_specifications,owner_id,owner_name,net_price,rule,rule_year,
      net_price,total_oec,oec_less_tax,reimbursement_rate,reimbursement_amount, note
    ]
  }
  }
