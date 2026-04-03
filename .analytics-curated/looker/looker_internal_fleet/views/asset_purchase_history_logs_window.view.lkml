include: "/views/asset_purchase_history_logs.view"

view: asset_purchase_history_logs_window {

  extends: [asset_purchase_history_logs]

  derived_table: {
    sql:
      SELECT
        PURCHASE_HISTORY_LOG_ID,
        PURCHASE_HISTORY_ID,
        OEC,
        DATE_GENERATED,
        GENERATED_BY_USER_ID,
        ARRAY_CONTAINS('oec'::variant, CHANGE_LIST) as oec_changed,
        LEAD(OEC, -1) OVER (PARTITION BY PURCHASE_HISTORY_ID ORDER BY PURCHASE_HISTORY_LOG_ID) AS previous_oec,
        CONDITIONAL_CHANGE_EVENT(FINANCIAL_SCHEDULE_ID IS NOT NULL) OVER (PARTITION BY PURCHASE_HISTORY_ID ORDER BY PURCHASE_HISTORY_LOG_ID) != 0 as financial_schedule_previously_assigned
      FROM
        ASSET_PURCHASE_HISTORY_LOGS ;;
  }

  dimension: oec_changed {
    type: yesno
    sql: ${TABLE}.oec_changed ;;
  }

  dimension: previous_oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}.previous_oec ;;
  }

  dimension: oec_changed_by {
    type: number
    value_format_name: percent_2
    sql: 1 - DIV0(${TABLE}.previous_oec, ${TABLE}.oec) ;;
  }

  dimension: financial_schedule_previously_assigned {
    type: yesno
    sql: ${TABLE}.financial_schedule_previously_assigned ;;
  }

}
