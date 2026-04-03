view: ukg_all_company_cost_centers {
  sql_table_name: "PAYROLL"."UKG_ALL_COMPANY_COST_CENTERS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    primary_key: yes
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: abbrev {
    type: string
    sql: ${TABLE}."ABBREV" ;;
  }
  dimension: defaults_weight {
    type: number
    sql: ${TABLE}."DEFAULTS_WEIGHT" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: intaact {
    type: number
    sql: ${TABLE}."INTAACT" ;;
  }
  dimension: is_visible {
    type: string
    sql: ${TABLE}."IS_VISIBLE" ;;
  }
  dimension: level {
    type: number
    sql: ${TABLE}."LEVEL" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: num_levels {
    type: number
    sql: ${TABLE}."NUM_LEVELS" ;;
  }
  dimension: tree_name {
    type: string
    sql: ${TABLE}."TREE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [name, tree_name, full_name]
  }
}
