view: claims_road {
  sql_table_name: "CLAIMS"."ROAD_UNION"
    ;;

  dimension: amount_collected_from_3_p {
    label: "Amount Collected"
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."AMOUNT_COLLECTED_FROM_3_P" ;;
  }

  dimension: amount_htd_es_paid {
    label: "Amount Paid"
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."AMOUNT_HTD_ES_PAID" ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_MAKE" ;;
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

  dimension: at_fault_payer {
    type: string
    sql: ${TABLE}."AT_FAULT_PAYER" ;;
  }

  dimension: claim_id {
    type: string
    sql: ${TABLE}."CLAIM_ID" ;;
    suggest_persist_for: "0 seconds"
  }

  dimension: claim_id_link_to_detail_dashboard {
    type: string
    sql: ${claim_id} ;;
    html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/610?Claim+ID={{ value | url_encode }}">{{rendered_value}}</a></p></u>;;
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

  dimension: driver_employee_id {
    type: number
    sql: ${TABLE}."DRIVER_EMPLOYEE_ID" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
    link: {
      label: "DISC Profile ({{ disc_master.environment_style._value }})"
      url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    }
    link: {
      label: "Greenhouse Profile"
      url: "{{ hr_greenhouse_link.greenhouse_link }}"
    }
  }

  dimension: file_notes {
    type: string
    sql: ${TABLE}."FILE_NOTES" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }

  dimension: google_drive_link {
    type: string
    sql: ${TABLE}."GOOGLE_DRIVE_LINK" ;;
    html:  <u><p style="color:Blue;"><a href="{{ claims_road.google_drive_link._value}}">Link To Accident Folder</a></p></u>;;
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
    label: "Market Name"
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: plate_ {
    type: string
    sql: ${TABLE}."PLATE_" ;;
  }

  dimension_group: repair_date {
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
    sql: CAST(${TABLE}."REPAIR_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: repair_invoice_ {
    type: string
    sql: ${TABLE}."REPAIR_INVOICE_" ;;
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

  dimension: total_amount_due_from_3_p {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT_DUE_FROM_3_P" ;;
  }

  dimension: total_amount_payable_by_htd_es_ {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT_PAYABLE_BY_HTD_ES_" ;;
  }

  dimension: comb_due_collected {
    label: "Due/Recovered"
    type: number
    sql: CASE WHEN ${status} = 'Open' THEN ${total_amount_due_from_3_p}
    WHEN ${status} = 'Closed' THEN ${amount_collected_from_3_p} end  ;;
  }

  dimension: comb_payable_paid {
    label: "Payable/Paid"
    type: number
    sql: CASE WHEN ${status} = 'Open' THEN ${total_amount_payable_by_htd_es_}
      WHEN ${status} = 'Closed' THEN ${amount_htd_es_paid} end  ;;
  }

  dimension: link {
    type: string
    sql: TO_DATE(${TABLE}."DATE_OF_LOSS") ;;
    html:  <u><p style="color:Blue;"><a href="https://app.estrack.com/#/assets/all/asset/{{claims_road.asset_number._value}}/history?selectedDate={{ value | url_encode }}">Link To ES Track</a></p></u>;;
  }

  dimension: is_material_loss {
    type: yesno
    sql: ${TABLE}."MATERIAL_LOSS_" = 'Yes' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: sum_payable_paid {
    type: sum
    sql: ${comb_payable_paid} ;;
    drill_fields: [detail*]
  }

  measure: sum_due_collected {
    type: sum
    sql: ${comb_due_collected} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      claim_id_link_to_detail_dashboard,
      date_of_loss_date,
      location,
      at_fault_payer,
      driver_name,
      comb_payable_paid,
      comb_due_collected,
      status,
      last_action_date_date,
      diary_last_action_taken
    ]
  }


  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: claims_road {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
