view: invoices {
  sql_table_name: "PUBLIC"."INVOICES"
    ;;
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

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

  dimension: are_tax_cals_missing {
    type: yesno
    sql: ${TABLE}."ARE_TAX_CALS_MISSING" ;;
  }

  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }

  dimension_group: avalara_transaction_id_update_dt_tm {
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
    sql: CAST(${TABLE}."AVALARA_TRANSACTION_ID_UPDATE_DT_TM" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: own_lsd_account {
    label: "Company Type"
    type: string
    sql: case
          when ${company_id} in (select esc.COMPANY_ID
                                 from "ANALYTICS"."PUBLIC"."ES_COMPANIES" as esc
                                 where owned = false) then 'LSD'
          when ${company_id} in (select esc.COMPANY_ID
                                 from "ANALYTICS"."PUBLIC"."ES_COMPANIES" as esc
                                 where owned = true) then 'ES'
          when ${company_id} in (SELECT DISTINCT aa.COMPANY_ID
                                 FROM "ES_WAREHOUSE"."PUBLIC"."V_PAYOUT_PROGRAMS" as vpp
                                 JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE" as aa
                                   ON vpp.ASSET_ID = aa.ASSET_ID
                                 WHERE CURRENT_TIMESTAMP >= vpp.START_DATE
                                   AND CURRENT_TIMESTAMP < COALESCE(vpp.END_DATE, '2099-12-31')) then 'OWN'
          else 'Customer'
          end;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: due_date_outstanding {
    type: number
    sql: ${TABLE}."DUE_DATE_OUTSTANDING" ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice_trunc {
    type: time
    sql: date_trunc(day,${TABLE}."INVOICE_DATE") ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_net_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: ordered_by_user_id {
    type: number
    sql: ${TABLE}."ORDERED_BY_USER_ID" ;;
  }

  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }

  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }

  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }

  dimension: ship_from {
    type: string
    sql: ${TABLE}."SHIP_FROM" ;;
  }

  dimension: ship_to {
    type: string
    sql: ${TABLE}."SHIP_TO" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${ship_from}:branch_id ;;
    value_format_name: id
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension_group: taxes_invalidated_dt_tm {
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
    sql: CAST(${TABLE}."TAXES_INVALIDATED_DT_TM" AS TIMESTAMP_NTZ) ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  dimension: invoice_branch {
    type: string
    value_format_name: id
    sql: coalesce(${invoices.branch_id},${line_items.branch_id}) ;;

  }

  measure: count {
    type: count
    drill_fields: [invoice_id, orders.purchase_order_id, line_items.count]
  }
}
