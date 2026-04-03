view: asset_purchase_history {
  sql_table_name: "PUBLIC"."ASSET_PURCHASE_HISTORY"
    ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: advance_payment_amount {
    type: number
    sql: ${TABLE}."ADVANCE_PAYMENT_AMOUNT" ;;
  }

  dimension: advance_payment_percent {
    type: number
    sql: ${TABLE}."ADVANCE_PAYMENT_PERCENT" ;;
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_invoice_url {
    type: string
    sql: ${TABLE}."ASSET_INVOICE_URL" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: delivery {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DELIVERY_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: document_preparation_fee {
    type: number
    sql: ${TABLE}."DOCUMENT_PREPARATION_FEE" ;;
  }

  dimension: downpayment_amount {
    type: number
    sql: ${TABLE}."DOWNPAYMENT_AMOUNT" ;;
  }

  dimension: downpayment_percent {
    type: number
    sql: ${TABLE}."DOWNPAYMENT_PERCENT" ;;
  }

  dimension: ebo_amount {
    type: number
    sql: ${TABLE}."EBO_AMOUNT" ;;
  }

  dimension_group: ebo {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."EBO_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: ebo_discount_percent {
    type: number
    sql: ${TABLE}."EBO_DISCOUNT_PERCENT" ;;
  }

  dimension_group: ebo_notification {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."EBO_NOTIFICATION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: ebo_percent {
    type: number
    sql: ${TABLE}."EBO_PERCENT" ;;
  }

  dimension: equipment_type_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_TYPE_ID" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: financed_amount {
    type: number
    sql: ${TABLE}."FINANCED_AMOUNT" ;;
  }

  dimension_group: financial_contract {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FINANCIAL_CONTRACT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: financial_contract_number {
    type: string
    sql: ${TABLE}."FINANCIAL_CONTRACT_NUMBER" ;;
  }

  dimension: financial_interest_rate {
    type: number
    sql: ${TABLE}."FINANCIAL_INTEREST_RATE" ;;
  }

  dimension: financial_lender {
    type: string
    sql: ${TABLE}."FINANCIAL_LENDER" ;;
  }

  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }

  dimension: financial_term {
    type: number
    sql: ${TABLE}."FINANCIAL_TERM" ;;
  }

  dimension: financing_facility_type_id {
    type: number
    sql: ${TABLE}."FINANCING_FACILITY_TYPE_ID" ;;
  }

  dimension: fppo_spo_balloon_amount {
    type: number
    sql: ${TABLE}."FPPO_SPO_BALLOON_AMOUNT" ;;
  }

  dimension_group: fppo_spo_balloon {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FPPO_SPO_BALLOON_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: fppo_spo_balloon_notification {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FPPO_SPO_BALLOON_NOTIFICATION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: fppo_spo_balloon_percent {
    type: number
    sql: ${TABLE}."FPPO_SPO_BALLOON_PERCENT" ;;
  }

  dimension: freight_amount {
    type: number
    sql: ${TABLE}."FREIGHT_AMOUNT" ;;
  }

  dimension: has_ebo_discount {
    type: yesno
    sql: ${TABLE}."HAS_EBO_DISCOUNT" ;;
  }

  dimension: has_fppo_spo_balloon_payment {
    type: yesno
    sql: ${TABLE}."HAS_FPPO_SPO_BALLOON_PAYMENT" ;;
  }

  dimension: interim_rent {
    type: number
    sql: ${TABLE}."INTERIM_RENT" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension_group: invoice_purchase {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."INVOICE_PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_financed {
    type: yesno
    sql: ${TABLE}."IS_FINANCED" ;;
  }

  dimension: is_owned {
    type: yesno
    sql: ${TABLE}."IS_OWNED" ;;
  }

  dimension: loan_origination_fee {
    type: number
    sql: ${TABLE}."LOAN_ORIGINATION_FEE" ;;
  }

  dimension: loan_status_type_id {
    type: number
    sql: ${TABLE}."LOAN_STATUS_TYPE_ID" ;;
  }

  dimension: loss_or_damage_remedies {
    type: string
    sql: ${TABLE}."LOSS_OR_DAMAGE_REMEDIES" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: payment_interval_1_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_1_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_1_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_1_MONTHS" ;;
  }

  dimension: payment_interval_2_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_2_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_2_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_2_MONTHS" ;;
  }

  dimension: payment_interval_3_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_3_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_3_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_3_MONTHS" ;;
  }

  dimension: payment_interval_4_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_4_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_4_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_4_MONTHS" ;;
  }

  dimension: payment_interval_5_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_5_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_5_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_5_MONTHS" ;;
  }

  dimension: payment_interval_6_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_6_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_6_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_6_MONTHS" ;;
  }

  dimension: payment_interval_7_monthly_payment {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_7_MONTHLY_PAYMENT" ;;
  }

  dimension: payment_interval_7_months {
    type: number
    sql: ${TABLE}."PAYMENT_INTERVAL_7_MONTHS" ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: previous_company_id {
    type: number
    sql: ${TABLE}."PREVIOUS_COMPANY_ID" ;;
  }

  dimension_group: purchase {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: purchase_history_id {
    type: number
    sql: ${TABLE}."PURCHASE_HISTORY_ID" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: purchase_order_url {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_URL" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: sales_tax {
    type: number
    sql: ${TABLE}."SALES_TAX" ;;
  }

  dimension: security_deposit {
    type: number
    sql: ${TABLE}."SECURITY_DEPOSIT" ;;
  }

  measure: count {
    type: count
    drill_fields: [assets.asset_id, assets.custom_name, assets.name, assets.driver_name]
  }
}
