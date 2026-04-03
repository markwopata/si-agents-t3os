view: credit_notes {
  sql_table_name: "PUBLIC"."CREDIT_NOTES"
    ;;
  drill_fields: [credit_note_id]

  dimension: credit_note_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
    link: {
      label: "Admin"
      url: "https://admin.equipmentshare.com/#/home/transactions/credit-notes/{{ value }}"
    }
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

  dimension: are_tax_calcs_missing {
    type: yesno
    sql: ${TABLE}."ARE_TAX_CALCS_MISSING" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    link: {
      label: "Admin"
      url: "https://admin.equipmentshare.com/#/home/companies/{{ value }}"
    }
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: credit_note_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
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

  dimension: erp_external_id {
    type: string
    sql: ${TABLE}."ERP_EXTERNAL_ID" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: originating_invoice_id {
    type: number
    sql: ${TABLE}."ORIGINATING_INVOICE_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: remaining_credit_amount {
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
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

  dimension: total_credit_amount {
    type: number
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_id, credit_note_types.credit_note_type_id, credit_note_types.name, credit_note_allocations.count, credit_note_line_items.count]
  }
}
