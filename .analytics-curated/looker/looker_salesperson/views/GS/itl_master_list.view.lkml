# The name of this view in Looker is "Itl Master List"
view: itl_master_list {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "GS"."ITL_MASTER_LIST"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called " Row" in Explore.

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total__row {
    type: sum
    sql: ${_row} ;;
  }

  measure: average__row {
    type: average
    sql: ${_row} ;;
  }

  dimension: day_benchmark {
    type: number
    sql: ${TABLE}."DAY_BENCHMARK" ;;
  }

  dimension: day_floor {
    type: number
    sql: ${TABLE}."DAY_FLOOR" ;;
  }

  dimension: day_online {
    type: number
    sql: ${TABLE}."DAY_ONLINE" ;;
  }

  dimension: day_to_week_ratio {
    type: number
    sql: ${TABLE}."DAY_TO_WEEK_RATIO" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: ${TABLE}."MONTH_BENCHMARK" ;;
  }

  dimension: month_floor {
    type: number
    sql: ${TABLE}."MONTH_FLOOR" ;;
  }

  dimension: month_online {
    type: number
    sql: ${TABLE}."MONTH_ONLINE" ;;
  }

  dimension: week_benchmark {
    type: number
    sql: ${TABLE}."WEEK_BENCHMARK" ;;
  }

  dimension: week_floor {
    type: number
    sql: ${TABLE}."WEEK_FLOOR" ;;
  }

  dimension: week_online {
    type: number
    sql: ${TABLE}."WEEK_ONLINE" ;;
  }

  dimension: week_to_month_ratio {
    type: number
    sql: ${TABLE}."WEEK_TO_MONTH_RATIO" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
