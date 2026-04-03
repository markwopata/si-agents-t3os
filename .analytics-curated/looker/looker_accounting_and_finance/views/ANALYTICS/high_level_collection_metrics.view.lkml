view: high_level_collection_metrics {
  sql_table_name: "ANALYTICS"."TREASURY"."HIGH_LEVEL_COLLECTION_METRICS" ;;

  ##### DIMENSIONS #####

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: quarter {
    type: string
    sql: case
        when ${month} in ('2025-01-31','2025-02-28','2025-03-31') then '2025-Q1'
        when ${month} in ('2025-04-30','2025-05-31','2025-06-30') then '2025-Q2'
        when ${month} in ('2025-07-31','2025-08-31','2025-09-30') then '2025-Q3'
        when ${month} in ('2025-10-31','2025-11-30','2025-12-31') then '2025-Q4'
        when ${month} in ('2026-01-31','2026-02-28','2026-03-31') then '2026-Q1'
        end ;;
  }

  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC" ;;
  }

  dimension: sub_metric_a {
    type: string
    sql: ${TABLE}."SUB_METRIC_A" ;;
  }

  dimension: sub_metric_a_notes {
    label: "Collector"
    type: string
    sql: ${TABLE}."SUB_METRIC_A" ;;
  }


  dimension: sub_metric_b {
    type: string
    sql: ${TABLE}."SUB_METRIC_B" ;;
  }

  dimension: sub_metric_b_notes {
    label: "Title"
    type: string
    sql: ${TABLE}."SUB_METRIC_B" ;;
  }

  dimension: sub_metric_b_collections {
    label: "Manager"
    type: string
    sql: ${TABLE}."SUB_METRIC_B" ;;
  }


  dimension: sub_metric_c {
    type: string
    sql: ${TABLE}."SUB_METRIC_C" ;;
  }


  dimension: sub_metric_c_notes {
    label: "Manager"
    type: string
    sql: ${TABLE}."SUB_METRIC_C" ;;
  }


  dimension: sub_metric_c_collections {
    label: "Title"
    type: string
    sql: ${TABLE}."SUB_METRIC_C" ;;
  }

  ##### MEASURES #####

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: total_amt_due {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets"]
  }

  measure: amt_current {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "Current"]
  }


  measure: pct_current {
    label: "Current"
    value_format_name: percent_1
    type: number
    sql: ${amt_current} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: amt_0_30_days {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "0 - 30 Days PD"]
  }

  measure: pct_0_30_days {
    label: "0 - 30 Days PD"
    value_format_name: percent_1
    type: number
    sql: ${amt_0_30_days} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: amt_31_60_days {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "31 - 60 Days PD"]
  }

  measure: pct_31_60_days {
    label: "31 - 60 Days PD"
    value_format_name: percent_1
    type: number
    sql: ${amt_31_60_days} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: amt_61_90_days {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "61 - 90 Days PD"]
  }

  measure: pct_61_90_days {
    label: "61 - 90 Days PD"
    value_format_name: percent_1
    type: number
    sql: ${amt_61_90_days} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: amt_91_120_days {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "91 - 120 Days PD"]
  }

  measure: pct_91_120_days {
    label: "91 - 120 Days PD"
    value_format_name: percent_1
    type: number
    sql: ${amt_91_120_days} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: amt_121_days {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "amt_due_aging_buckets", sub_metric_a: "121+ Days PD"]
  }

  measure: pct_121_days {
    label: "121+ Days PD"
    value_format_name: percent_1
    type: number
    sql: ${amt_121_days} / NULLIF(${total_amt_due}, 0) ;;
  }

  measure: note_count {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "note"]
  }

  measure: business_days {
    type: average
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "business_days"]
  }

  measure: calendar_days {
    type: average
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "calendar_days"]
  }

  measure: collector_count {
    type: average
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "collector_count"]
  }

  measure: average_customer_notes {
    type: average
    value_format_name: decimal_1
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "note"]
    drill_fields: [collection_details*]
  }


  measure: average_notes {
    value_format_name: decimal_1
    type: number
    drill_fields: [note_details*]
    sql: case
         when ${average_customer_notes} = 0 then 0
        else ${average_customer_notes}/${business_days}/${collector_count} end
        ;;
  }

  measure: total_collected_dollars {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "total_dollars_collected"]
  }

  measure: collections_goal {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "collections_goal"]
  }

  measure: average_customer_collections {
    type: average
    value_format_name: usd_0
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "total_dollars_collected"]
    drill_fields: [collection_details*]
  }


  measure: average_collections {
    value_format_name: usd_0
    type: number
    drill_fields: [collection_details*]
    sql: case
         when ${average_customer_collections} = 0 then 0
        else ${average_customer_collections}/${business_days}/${collector_count} end
        ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "revenue"]
  }


  measure: total_ar {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "total_ar"]
  }


  measure: monthly_dso  {
    label: "DSO"
    type: number
    value_format_name: decimal_1
    sql:  (${total_ar}/${total_revenue}) * ${calendar_days}  ;;
  }


  measure: calendar_days_quarterly {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "calendar_days"]
  }

  dimension: is_quarter_end {
    type: yesno
    sql: MONTH(${month}::date) IN (3, 6, 9, 12) ;;
  }

  measure: total_ar_qtr_end {
    hidden: yes
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    filters: [metric: "total_ar", is_quarter_end: "yes"]
  }

  measure: quarterly_dso {
    label: "Quarterly DSO"
    type: number
    value_format_name: decimal_1
    sql: (${total_ar_qtr_end} / NULLIF(${total_revenue}, 0)) * ${calendar_days_quarterly} ;;
  }


##### DRILL FIELDS #####

  set: note_details {
    fields: [month,sub_metric_a_notes,sub_metric_c_notes,sub_metric_b_notes,note_count]
  }

  set: collection_details {
    fields: [month,sub_metric_a_notes,sub_metric_b_collections,sub_metric_c_collections,total_collected_dollars]
  }

}
