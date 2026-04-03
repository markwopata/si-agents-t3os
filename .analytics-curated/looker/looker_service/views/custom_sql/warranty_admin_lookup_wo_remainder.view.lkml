view: warranty_admin_lookup_wo_remainder {
  derived_table: {
    sql:
      select *
      from ANALYTICS.WARRANTIES.ADMIN_LOOKUP_TOOL_REMAINDER
      where region_name ilike concat('%', {% parameter region_name_param %}, '%') ;;
  }

  dimension_group: reference {
    type: time
    timeframes: [
      date
      , month
      , year
    ]
    convert_tz: no
    sql: ${TABLE}.reference_date ;;
  }

  dimension_group: snapshot {
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
    convert_tz: no
    sql: ${TABLE}.snapshot_timestamp ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district_name ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  dimension: warranty_state {
    type: string
    sql: ${TABLE}.warranty_state ;;
  }

  dimension: possible_missed_opp_line {
    type: yesno
    sql: iff(${warranty_state} ilike 'Possible Missed Opp', TRUE, FALSE) ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Warranty Admin"}
    allowed_value: { value: "OEM"}
    allowed_value: { value: "Billed Company"}
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  dimension: dynamic_axis {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Warranty Admin'" %}
      ${warranty_admin}
    {% elsif drop_down_selection._parameter_value == "'OEM'" %}
      ${make}
    {% elsif drop_down_selection._parameter_value == "'Billed Company'" %}
      NULL
    {% elsif drop_down_selection._parameter_value == "'Region'" %}
      ${region}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market}
    {% else %}
      NULL
    {% endif %} ;;
  }


  dimension: work_orders_remaining {
    type: number
    sql: ${TABLE}.work_orders_remaining ;;
  }

  measure: total_work_orders_remaining {
    type: sum
    filters: [possible_missed_opp_line: "no"]
    sql: ${work_orders_remaining} ;;
  }

  measure: total_work_orders_remaining_drill_state {
    type: sum
    filters: [possible_missed_opp_line: "no"]
    sql: ${work_orders_remaining} ;;
    drill_fields: [
      warranty_state
      , total_work_orders_remaining_drill_state
    ]
  }

  measure: total_work_orders_remaining_drill {
    type: sum
    sql: ${work_orders_remaining} ;;
    filters: [possible_missed_opp_line: "no"]
    drill_fields: [
      reference_date
      , warranty_state
      , total_work_orders_remaining_drill
    ]
  }

  measure: count_of_days {
    type: count_distinct
    sql: ${reference_date} ;;
  }

  measure: avg_work_orders_remaining_for_overview {
    type: number
    sql: ${total_work_orders_remaining} / ${count_of_days} ;;
    drill_fields: [
      market
      , warranty_admin
      , make
      , avg_work_orders_remaining_for_overview_drill
    ]
  }

  measure: avg_work_orders_remaining_for_overview_drill {
    type: number
    sql: ${total_work_orders_remaining} / ${count_of_days} ;;
    drill_fields: [
      reference_date
      , market
      , warranty_admin
      , make
      , total_work_orders_remaining_drill_state
    ]
  }

  measure: avg_work_orders_remaining {
    type: number
    sql: ${total_work_orders_remaining} / ${count_of_days} ;;
    drill_fields: [
      dynamic_axis
      , warranty_state
      , avg_work_orders_remaining_drill
    ]
  }

  measure: avg_work_orders_remaining_drill {
    type: number
    sql: ${total_work_orders_remaining} / ${count_of_days} ;;
    drill_fields: [
      reference_date
      , dynamic_axis
      , total_work_orders_remaining_drill
    ]
  }

  # dimension: possible_missed_opp_remaining {
  #   type: number
  #   sql: ${TABLE}.possible_missed_opp_remaining ;;
  # }

  measure: total_possible_missed_opp_remaining  {
    type: sum
    filters: [possible_missed_opp_line: "yes"]
    sql: ${work_orders_remaining} ;;
  }

  measure: total_possible_missed_opp_remaining_drill {
    type: sum
    filters: [possible_missed_opp_line: "yes"]
    sql: ${work_orders_remaining} ;;
    drill_fields: [
      reference_date
      , warranty_state
      , total_possible_missed_opp_remaining_drill
    ]
  }

  measure: total_possible_missed_opp_remaining_drill_state  {
    type: sum
    filters: [possible_missed_opp_line: "yes"]
    sql: ${work_orders_remaining} ;;
    drill_fields: [
      warranty_state
      , total_possible_missed_opp_remaining_drill_state
    ]
  }

  measure: avg_possible_missed_opp_remaining_for_overview {
    type: number
    sql: ${total_possible_missed_opp_remaining} / ${count_of_days} ;;
    drill_fields: [
      market
      , warranty_admin
      , make
      , avg_possible_missed_opp_remaining_for_overview_drill
    ]
  }

  measure: avg_possible_missed_opp_remaining_for_overview_drill {
    type: number
    sql: ${total_possible_missed_opp_remaining} / ${count_of_days} ;;
    drill_fields: [
      reference_date
      , market
      , warranty_admin
      , make
      , total_possible_missed_opp_remaining_drill_state
    ]
  }

  measure: avg_possible_missed_opp_remaining {
    type: number
    sql: ${total_possible_missed_opp_remaining} / ${count_of_days} ;;
    drill_fields: [
      dynamic_axis
      , warranty_state
      , avg_possible_missed_opp_remaining_drill
    ]
  }

  measure: avg_possible_missed_opp_remaining_drill {
    type: number
    sql: ${total_possible_missed_opp_remaining} / ${count_of_days} ;;
    drill_fields: [
      reference_date
      , dynamic_axis
      , total_possible_missed_opp_remaining_drill
    ]
  }

  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }

  parameter: region_name_param {
    type: string
    allowed_value: {
      value: "Pacific"
    }
    allowed_value: {
      value: "Mountain West"
    }
    allowed_value: {
      value: "Southeast"
    }
    allowed_value: {
      value: "Southwest"
    }
    allowed_value: {
      value: "Midwest"
    }
    allowed_value: {
      value: "Southeast"
    }
    allowed_value: {
      value: "Northeast"
    }
    allowed_value: {
      value: "Industrial"
    }
    allowed_value: {
      label: "any value"
      value: "%"
    }
  }
}
