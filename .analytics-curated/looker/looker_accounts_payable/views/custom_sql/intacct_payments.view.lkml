
view: intacct_payments {
  derived_table: {
    sql: SELECT
          APH.VENDORID         AS VENDORD_ID,
          VEND.NAME            AS VENDOR_NAME,
          APH.STATE            AS PAYMENT_STATUS,
          APH.PAYMENTTYPE      AS PAYMENT_METHOD,
          APH.PAYMENTDATE      AS PAYMENT_DATE,
          APH.PAYMENTAMOUNT    AS PAYMENT_AMOUNT,
          APH.ENTITY           AS ENTITY,
          APH.FINANCIALACCOUNT AS BANK_ACCOUNT
      FROM
          ANALYTICS.INTACCT.APRECORD APH
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
      WHERE
            APH.RECORDTYPE = 'appayment';;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendord_id {
    type: string
    sql: ${TABLE}."VENDORD_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_amount {
    type: number
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: bank_account {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT" ;;
  }

  set: detail {
    fields: [
        vendord_id,
  vendor_name,
  payment_status,
  payment_method,
  payment_date,
  payment_amount,
  entity,
  bank_account
    ]
  }
}
