view: warranty_missed_opp_weekly_report {
  sql_table_name: ANALYTICS.WARRANTIES.MISSED_OPP_REVIEWED_WO ;;

  dimension: report_date {
    type: date
    sql: ${TABLE}.report_date ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id;;
  }

  measure: wo_reviewed {
    type: count
    drill_fields: [detail*]
  }

  dimension: wo_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_cost;;
  }

  measure: value_reviewed {
    type: sum
    value_format_name: usd_0
    sql: ${wo_cost} ;;
    drill_fields: [detail*]
  }

  dimension: flipped_warranty {
    type: yesno
    sql: ${TABLE}.flipped_warranty ;;
  }

  measure: wo_flipped {
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [flipped_warranty: "yes"]
    drill_fields: [detail*]
  }

  dimension: flipped_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.flipped_value ;;
  }

  measure: value_flipped {
    type: sum
    value_format_name: usd_0
    sql: ${flipped_value};;
    filters: [flipped_warranty: "yes"]
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: billed_warranty {
    type: yesno
    sql: ${TABLE}.billed_warranty ;;
  }

  measure: wo_billed_warranty {
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [billed_warranty: "yes"]
    drill_fields: [detail*]
  }

  dimension: claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claimed;;
  }

  measure: total_claims {
    type: sum
    value_format_name: usd_0
    sql: ${claimed} ;;
    filters: [billed_warranty: "yes"]
    drill_fields: [detail*]
  }

  dimension: paid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.paid;;
  }

  measure: total_paid {
    type: sum
    value_format_name: usd_0
    sql: ${paid} ;;
    filters: [billed_warranty: "yes"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [ work_orders.work_order_id_with_link_to_work_order
      , work_orders.description
      , wo_cost
      , flipped_warranty
      , billed_warranty
      , assets_aggregate.asset_id
      , assets_aggregate.make
      , assets_aggregate.model
      , warranty_invoice_asset_info.invoice_no
      , warranty_invoice_asset_info.admin_link_to_invoice
      , warranty_invoice_asset_info.date_created_date
      , warranty_invoice_asset_info.total_invoice_amount
      , warranty_invoice_asset_info.total_invoice_amount_paid
      , warranty_invoice_asset_info.total_invoice_amount_pending
      , warranty_invoice_asset_info.total_invoice_amount_denied
    ]
  }
  }
