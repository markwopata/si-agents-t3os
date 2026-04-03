view: FACT_TIME_ENTRY {
  sql_table_name: "BRANCH_EARNINGS"."FACT_TIME_ENTRY";;

  filter: PERIOD_FILTER {
    type: string
    suggest_dimension: FILTER_DATE.FILTER_PERIOD
  }

  dimension: PERIOD_SATISFIES_FILTER {
    type: yesno
    hidden: no
    sql: {% condition PERIOD_FILTER %} DIM_DATE_LIVE_BE.PERIOD {% endcondition %} ;;
  }

  dimension: NEXT_PERIOD_SATISFIES_FILTER {
    type: yesno
    hidden: no
    sql: {% condition PERIOD_FILTER %} DIM_DATE_LIVE_BE.NEXT_PERIOD {% endcondition %} ;;
  }

  dimension: PK_FACT_TIME_ENTRY {
    type: number
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_FACT_TIME_ENTRY" ;;
  }

  dimension: FK_MARKET {
    type: string
    sql: ${TABLE}."FK_MARKET" ;;
  }

  dimension: FK_ASSET {
    type: string
    sql: ${TABLE}."FK_ASSET" ;;
  }

  dimension: FK_EMPLOYEE {
    type: string
    sql: ${TABLE}."FK_EMPLOYEE" ;;
  }

  dimension: FK_WORK_ORDER {
    type: string
    sql: ${TABLE}."FK_WORK_ORDER" ;;
  }

  dimension: FK_DATE {
    type: date
    sql: ${TABLE}."FK_DATE" ;;
  }

  dimension: REGULAR_HOURS {
    type: number
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }

  dimension: OVERTIME_HOURS {
    type: number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    hidden: yes
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    hidden: yes
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF FACT RECORDS"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_REGULAR_HOURS {
    type: sum
    label: "TOTAL REGULAR HOURS"
    sql: ${REGULAR_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_REGULAR_HOURS {
    type: sum
    label: "SELECTED PERIOD REGULAR HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REGULAR_HOURS};;
    filters: [PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_REGULAR_HOURS {
    type: sum
    label: "PRIOR PERIOD REGULAR HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REGULAR_HOURS};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_OVERTIME_HOURS {
    type: sum
    label: "TOTAL OVERTIME HOURS"
    hidden: no
    sql: ${OVERTIME_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_OVERTIME_HOURS {
    type: sum
    label: "SELECTED PERIOD OVERTIME HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    hidden: no
    sql: ${OVERTIME_HOURS};;
    filters: [PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_OVERTIME_HOURS {
    type: sum
    label: "PRIOR PERIOD OVERTIME HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    hidden: no
    sql: ${OVERTIME_HOURS};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_HOURS {
    type: number
    label: "TOTAL HOURS"
    sql: ${TOTAL_REGULAR_HOURS} + ${TOTAL_OVERTIME_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_HOURS {
    type: number
    label: "SELECTED PERIOD HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PERIOD_PARAMETER_TOTAL_REGULAR_HOURS} + ${PERIOD_PARAMETER_TOTAL_OVERTIME_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_HOURS {
    type: number
    label: "PRIOR PERIOD HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PRIOR_PERIOD_PARAMETER_TOTAL_REGULAR_HOURS} + ${PRIOR_PERIOD_PARAMETER_TOTAL_OVERTIME_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_UNASSIGNED_HOURS {
    type: sum
    label: "TOTAL UNASSIGNED HOURS"
    filters: [DIM_WORK_ORDER.WORK_ORDER_ID: "-1"]
    sql: ${REGULAR_HOURS} + ${OVERTIME_HOURS};;
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_UNASSIGNED_HOURS {
    type: sum
    label: "SELECTED PERIOD UNASSIGNED HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REGULAR_HOURS} + ${OVERTIME_HOURS};;
    filters: [DIM_WORK_ORDER.WORK_ORDER_ID: "-1", PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_UNASSIGNED_HOURS {
    type: sum
    label: "PRIOR PERIOD UNASSIGNED HOURS"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REGULAR_HOURS} + ${OVERTIME_HOURS};;
    filters: [DIM_WORK_ORDER.WORK_ORDER_ID: "-1", NEXT_PERIOD_SATISFIES_FILTER: "yes"]
    value_format: "#,##0.00;(#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERCENT_UNASSIGNED {
    type: number
    label: "PERCENT UNASSIGNED"
    sql: ${TOTAL_UNASSIGNED_HOURS} / NULLIF(${TOTAL_HOURS}, 0);;
    value_format: "0.00%"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_PERCENT_UNASSIGNED {
    type: number
    label: "SELECTED PERIOD PERCENT UNASSIGNED"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PERIOD_PARAMETER_TOTAL_UNASSIGNED_HOURS} / NULLIF(${PERIOD_PARAMETER_TOTAL_HOURS}, 0);;
    value_format: "0.00%"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_PERCENT_UNASSIGNED {
    type: number
    label: "PRIOR PERIOD PERCENT UNASSIGNED"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PRIOR_PERIOD_PARAMETER_TOTAL_UNASSIGNED_HOURS} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_HOURS}, 0);;
    value_format: "0.00%"
    drill_fields: [drill_detail*]
  }

  set: drill_detail {
    fields: [DIM_DATE_LIVE_BE.DATE, DIM_WORK_ORDER.STATUS, DIM_WORK_ORDER.WORK_ORDER_TYPE_NAME, DIM_WORK_ORDER.WORK_ORDER_ID, DIM_WORK_ORDER.WORK_ORDER_DESCRIPTION, DIM_MARKET.MARKET_NAME, DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.CURRENT_OEC, REGULAR_HOURS, OVERTIME_HOURS]
  }
}
