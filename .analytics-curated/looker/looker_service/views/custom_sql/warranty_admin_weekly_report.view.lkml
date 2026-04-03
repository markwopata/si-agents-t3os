view: warranty_admin_weekly_report {
  sql_table_name: ANALYTICS.WARRANTIES.ADMIN_WEEKLY_REPORT ;;

dimension: report_date {
  type: date
  sql: ${TABLE}.report_date ;;
}

dimension: admin {
  type: string
  sql: ${TABLE}.admin ;;
}

dimension: equipment_make_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.equipment_make_id ;;
}

dimension: region_name {
  type: string
  sql: ${TABLE}.region_name ;;
}

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

dimension: reviewed_wo {
  type: number
  sql: ${TABLE}.reviewed_wo ;;
}

  measure: wo_reviewed {
    type: sum
    sql: ${reviewed_wo} ;;
    drill_fields: [drill*]
  }

  dimension: value_reviewed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.reviewed_value ;;
}

measure: reviewed_value {
  type: sum
  value_format_name: usd_0
  sql: ${value_reviewed} ;;
  drill_fields: [drill*]
}

  dimension: warranty_wo_reviewed {
    type: number
    sql: ${TABLE}.warranty_wo_reviewed ;;
  }

  measure: wo_w_warranty_reviewed {
    type: sum
    sql: ${warranty_wo_reviewed} ;;
    drill_fields: [drill*]
  }

  dimension: value_warranty_reviewed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warranty_reviewed_value ;;
  }

  measure: warranty_reviewed_value {
    type: sum
    value_format_name: usd_0
    sql: ${value_warranty_reviewed} ;;
    drill_fields: [drill*]
  }

dimension: wo_flipped {
  type: number
  sql: ${TABLE}.flipped_wo ;;
}

measure: flipped_wo {
  type: sum
  sql: ${wo_flipped} ;;
}

  dimension: value_flipped {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.flipped_value  ;;
  }

  measure: flipped_value {
    type: sum
    value_format_name: usd_0
    sql: ${value_flipped} ;;
    drill_fields: [drill*]
  }

  dimension: more_info_needed_tagged {
    type: number
    sql: ${TABLE}.tagged_needs_more_info ;;
  }

  measure: tagged_needs_more_info {
    type: sum
    sql: ${more_info_needed_tagged} ;;
  }

  dimension: value_tagged {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.tagged_value;;
  }

  measure: tagged_value {
    type: sum
    value_format_name: usd_0
    sql: ${value_tagged} ;;
    drill_fields: [drill*]
  }

dimension: claims_filed {
  type: number
  sql: ${TABLE}.claims_filed;;
}

  measure: filed_claims {
    type: sum
    sql: ${claims_filed} ;;
    drill_fields: [drill*]
  }

  dimension: value_filed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.filed_value;;
  }

  measure: filed_value {
    type: sum
    value_format_name: usd_0
    sql: ${value_filed} ;;
    drill_fields: [drill*]
  }

  dimension: total_days_to_claim {
    type: number
    sql: ${TABLE}.total_days_to_claim ;;
  }

  measure: sum_days_to_claim {
    type: sum
    sql: ${total_days_to_claim};;
  }

  dimension: divided_by { #have to do this so we aren't averaging averages
    type: number
    sql: ${TABLE}.divide_by  ;;
  }

  measure: invoices_w_wo {
    type: sum
    sql: ${divided_by} ;;
  }

dimension: days_to_claim {
  type: number
  value_format_name: decimal_1
  sql: ${TABLE}.days_to_claim ;;
}

dimension: closed_claims {
  type: number
  sql: ${TABLE}.closed_claims ;;
}

measure: claims_closed {
  type: sum
  sql: ${closed_claims} ;;
  drill_fields: [drill*]
}

  dimension: value_closed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.closed_paid_value;;
  }

  measure: closed_paid_value {
    type: sum
    value_format_name: usd_0
    sql: ${value_closed} ;;
    drill_fields: [drill*]
}

set: drill {
  fields: [
    report_date,
    admin,
    make,
    wo_reviewed,
    wo_w_warranty_reviewed,
    filed_claims,
    claims_closed,
    warranty_admin_lookup_wo_remainder.work_orders_to_review
  ]
}
}
