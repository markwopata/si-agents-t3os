view: claims_damage {
  sql_table_name: "CLAIMS"."DAMAGE_UNION"
    ;;

  dimension: amount_due {
    type: number
    sql: ${TABLE}."AMOUNT_DUE" ;;
    value_format: "$#,##0.00"
  }

  dimension: amount_hts_es_paid {
    type: number
    sql: ${TABLE}."AMOUNT_HTS_ES_PAID" ;;
    value_format: "$#,##0.00"
  }

  dimension: asset_make_ {
    type: string
    sql: ${TABLE}."ASSET_MAKE_" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_MODEL" ;;
  }

  dimension: asset_number {
    type: string
    sql: ${TABLE}."ASSET_NUMBER" ;;
  }

  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
  }

  dimension: claim_id {
    type: string
    sql: ${TABLE}."CLAIM_ID" ;;
  }

  dimension: claim_type {
    type: string
    sql: ${TABLE}."CLAIM_TYPE" ;;
  }

  dimension: collected {
    type: number
    sql: ${TABLE}."COLLECTED" ;;
    value_format: "$#,##0.00"
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_no {
    type: string
    sql: ${TABLE}."CUSTOMER_NO" ;;
  }

  dimension_group: date_of_loss {
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
    sql: CAST(${TABLE}."DATE_OF_LOSS" AS TIMESTAMP_NTZ) ;;
  }

  dimension: diary_last_action_taken {
    type: string
    sql: ${TABLE}."DIARY_LAST_ACTION_TAKEN" ;;
  }

  dimension: file_notes {
    type: string
    sql: ${TABLE}."FILE_NOTES" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }

  dimension_group: last_action_date {
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
    sql: CAST(${TABLE}."LAST_ACTION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: loss_type {
    type: string
    sql: ${TABLE}."LOSS_TYPE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: rental_date {
    type: string
    sql: ${TABLE}."RENTAL_DATE" ;;
  }

  dimension: rental_number {
    type: string
    sql: ${TABLE}."RENTAL_NUMBER" ;;
  }

  dimension: repair_date {
    type: string
    sql: ${TABLE}."REPAIR_DATE" ;;
  }

  dimension: repair_invoice_ {
    type: string
    sql: ${TABLE}."REPAIR_INVOICE_" ;;
  }

  dimension: reported_by {
    type: string
    sql: ${TABLE}."REPORTED_BY" ;;
  }

  dimension: responsible_payer {
    type: string
    sql: ${TABLE}."RESPONSIBLE_PAYER" ;;
  }

  dimension: responsible_payer_filter{
    type: string
    sql:  ;;
  }

  dimension: rpp_charge_amount {
    type: number
    sql: ${TABLE}."RPP_CHARGE_AMOUNT" ;;
  }

  dimension: rpp_indicator {
    type: string
    sql: ${TABLE}."RPP_INDICATOR" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: status_comments {
    type: string
    sql: ${TABLE}."STATUS_COMMENTS" ;;
  }

  dimension: work_order {
    type: string
    sql: ${TABLE}."WORK_ORDER" ;;
  }

  dimension: comb_due_collected {
     label: "Due/Recovered"
     type: number
     sql: CASE WHEN ${status} = 'Open' THEN ${amount_due}
     WHEN ${status} = 'Closed' THEN ${collected} end  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: sum_due_collected {
    type: sum
    sql: ${comb_due_collected} ;;
    drill_fields: [detail*]
    value_format: "$#,##0.00"
  }

  set: detail {
    fields: [
      #claim_id_link_to_detail_dashboard,
      date_of_loss_date,
      location,
      #at_fault_payer,
      #driver_name,
      #comb_payable_paid,
      comb_due_collected,
      status,
      last_action_date_date,
      diary_last_action_taken
    ]
  }

}
