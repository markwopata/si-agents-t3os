view: work_order_summary {

  derived_table: {
    sql:
    SELECT WOBT.WORK_ORDER_ID AS WORK_ORDER_ID, WOBT.NAME AS TAG, WOBT.USER_ID AS USER_ID,
WOBT.DATE_CREATED::DATE AS DATE_CREATED, WOBT.DATE_COMPLETED::DATE AS DATE_COMPLETED,
WO.URGENCY_LEVEL_ID AS URGENCY_LEVEL_ID, URG.NAME AS URGENCY_LEVEL,
WO.WORK_ORDER_STATUS_ID AS WORK_ORDER_STATUS_ID, WS.NAME AS WORK_ORDER_STATUS,
WO.DESCRIPTION AS DESCRIPTION, WO.DUE_DATE::DATE AS DUE_DATE,
WO.BILLING_NOTES AS BILLING_NOTES,
WO.INVOICE_NUMBER AS INVOICE_NUMBER, WO.ASSET_ID AS ASSET_ID
FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS_BY_TAG AS WOBT
LEFT JOIN  ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS AS WO
ON WOBT.WORK_ORDER_ID = WO.WORK_ORDER_ID
LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.URGENCY_LEVELS AS URG
ON WO.URGENCY_LEVEL_ID = URG.URGENCY_LEVEL_ID
LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_STATUSES AS WS
ON WO.WORK_ORDER_STATUS_ID = WS.WORK_ORDER_STATUS_ID
AND WOBT.USER_ID IN (
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


                         ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}.WORK_ORDER_ID ;;
  }

  dimension: tag {
    type: string
    sql: ${TABLE}.TAG ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension: date_completed {
    type: date
    sql: ${TABLE}.DATE_COMPLETED ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}.URGENCY_LEVEL_ID ;;
  }

  dimension: urgency_level {
    type: string
    sql: ${TABLE}.URGENCY_LEVEL ;;
  }

  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}.WORK_ORDER_STATUS_ID ;;
  }

  dimension: work_order_status {
    type: string
    sql: ${TABLE}.WORK_ORDER_STATUS ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}.BILLING_NOTES ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }
  }
