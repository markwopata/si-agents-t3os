view: payroll_hours {

  derived_table: {
    sql:
    SELECT TTE.WORK_ORDER_ID AS WORK_ORDER_ID,
TTE.USER_ID AS USER_ID ,
TTE.START_DATE::DATE AS START_DATE, TTE.END_DATE::DATE AS END_DATE,
SUM(TTE.OVERTIME_HOURS) AS OT_HOURS,
SUM(TTE.REGULAR_HOURS) - SUM(TTE.OVERTIME_HOURS) AS REG_HOURS, SUM(TTE.REGULAR_HOURS) AS TOTAL_HOURS
FROM ES_WAREHOUSE.TIME_TRACKING.ENTRY_RECORDS AS TTE
WHERE TTE.APPROVAL_STATUS = 'Approved' AND TTE.EVENT_TYPE_ID = 1
AND TTE.USER_ID IN (
63470,
65740,
59776,
61395,
46481,
32231,
31851,
50364,
63831,
17336,
61701,
33360,
11580,
63377,
65195,
57462,
51121,
50324,
19805,
45923,
62500,
31470,
15178,
29900,
45947,
59271,
20049,
12168,
19467,
53765,
32742,
52634,
55920,
16395,
30225,
55438,
37464,
38310,
59794,
16086,
42346,
61689,
29111,
53135,
65753,
54305,
20529,
24259,
28002,
10080,
28000,
7822,
16803,
11700,
9519,
20558,
31040,
36719,
12313,
19963,
15520,
15780
    )
GROUP BY TTE.WORK_ORDER_ID,  TTE.USER_ID, TTE.START_DATE::DATE, TTE.END_DATE::DATE

                         ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}.WORK_ORDER_ID ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}.START_DATE ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}.END_DATE ;;
  }

  dimension: lookup_date {
    type: date
    sql: case when ${start_date} = ${end_date} then ${start_date} else ${end_date} end ;;
  }



  measure: overtime_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [payroll_details*]
    sql: ${TABLE}.OT_HOURS ;;
  }

  measure: regular_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [payroll_details*]
    sql: ${TABLE}.REG_HOURS  ;;
  }

  measure: total_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [payroll_details*]
    sql: ${TABLE}.TOTAL_HOURS ;;
  }

  set: wo_details {
    fields: [work_order_summary.work_order_id,work_order_summary.tag,work_order_summary.user_id,users.full_name,work_order_summary.asset_id,work_order_summary.urgency_level,work_order_summary.work_order_status,
              work_order_summary.invoice_number,work_order_summary.date_created,work_order_summary.date_completed,work_order_summary.due_date,work_order_summary.description,work_order_summary.billing_notes]
  }

  set: payroll_details {
    fields: [user_id,users.full_name,start_date,end_date,regular_hours,overtime_hours,total_hours,ot_pct_total]
  }

  measure: work_order_count {
    type: count_distinct
    drill_fields: [wo_details*]
    sql: ${work_order_id} ;;
  }

  measure: hours_per_work_order {
    type: number
    value_format_name: decimal_2
    sql:case when ${work_order_count} = 0 then 0 else ${total_hours} / ${work_order_count} end ;;
  }

  measure: hours_on_wo {
    type: number
    sql: ${total_hours} where ${work_order_id} is not null ;;
  }

  measure: ratio_of_hours {
    type: number
    sql: ${hours_on_wo} / ${total_hours} ;;
  }

  measure: ot_pct_total {
    type: number
    value_format_name: percent_2
    drill_fields: [payroll_details*]
    sql: ${overtime_hours} / ${total_hours} ;;
  }

  }
