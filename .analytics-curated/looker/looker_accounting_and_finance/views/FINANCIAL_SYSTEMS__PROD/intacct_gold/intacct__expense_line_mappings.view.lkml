view: intacct__expense_line_mappings {
  sql_table_name: "INTACCT_GOLD"."INTACCT__EXPENSE_LINE_MAPPINGS" ;;

  dimension: id_expense_line {
    type: number
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: fk_dimension_value_id {
    type: number
    sql: ${TABLE}."FK_DIMENSION_VALUE_ID" ;;
    value_format_name: id
  }

  dimension: category_expense {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE" ;;
  }

  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }

  dimension: type_dimension {
    type: string
    sql: ${TABLE}."TYPE_DIMENSION" ;;
  }

  dimension: type_dimension_value {
    type: string
    sql: ${TABLE}."TYPE_DIMENSION_VALUE" ;;
  }

  dimension: id_dimension_value {
    type: string
    sql: ${TABLE}."ID_DIMENSION_VALUE" ;;
  }

  dimension: name_dimension_value {
    type: string
    sql: ${TABLE}."NAME_DIMENSION_VALUE" ;;
  }

  dimension: status_dimension_value {
    type: string
    sql: ${TABLE}."STATUS_DIMENSION_VALUE" ;;
  }

  dimension: is_expense_line_discontinued {
    type: yesno
    sql: ${TABLE}."IS_EXPENSE_LINE_DISCONTINUED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_invalid_mapping {
    type: yesno
    sql: ${TABLE}."IS_INVALID_MAPPING" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension_group: timestamp_expense_line_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_EXPENSE_LINE_LOADED" ;;
  }

  dimension_group: timestamp_dimension_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DIMENSION_LOADED" ;;
  }

  dimension_group: timestamp_mapping_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MAPPING_LOADED" ;;
  }

  measure: count {
    type: count
  }
}
