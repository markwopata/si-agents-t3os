view: work_order_for_payroll {

  derived_table: {
    sql:
       SELECT  WO.WORK_ORDER_ID AS WORK_ORDER_ID, WOS.NAME AS WORK_ORDER_STATUS,
WO.URGENCY_LEVEL_ID AS URGENCY_LEVEL_ID,
WO.DESCRIPTION AS DESCRIPTION, WO.ASSET_ID AS ASSET_ID,
WO.CREATOR_USER_ID AS CREATOR_USER_ID, U.FIRST_NAME||', '||U.LAST_NAME AS CREATOR_NAME,
U.EMPLOYEE_ID AS CREATOR_PAYCOR_ID,
WO.BRANCH_ID AS BRANCH_ID, WO.SEVERITY_LEVEL_ID AS SEVERITY_LEVEL_ID,
WOT.NAME AS WORK_ORDER_TYPE,
WO.MILEAGE_AT_SERVICE AS MILEAGE_AT_SERVICE, WO.HOURS_AT_SERVICE AS HOURS_AT_SERVICE,
WO.DUE_DATE AS DUE_DATE, WO.DATE_CREATED AS DATE_CREATED,  WO.DATE_COMPLETED AS DATE_COMPLETED,
CASE WHEN WO.DATE_COMPLETED IS NULL THEN datediff(SECONDS, WO.DATE_CREATED, CURRENT_TIMESTAMP)/3600
ELSE datediff(SECONDS, WO.DATE_CREATED, WO.DATE_COMPLETED)/3600 END as HOURS_SPENT_ON_WORK_ORDER,
CASE WHEN WO.DUE_DATE IS NULL THEN 'No Due Date'
WHEN WO.DATE_COMPLETED > WO.DUE_DATE THEN 'Past Due'
WHEN WO.DATE_COMPLETED <= WO.DUE_DATE THEN 'On Time'
WHEN WO.DATE_COMPLETED IS NULL AND CURRENT_TIMESTAMP > WO.DUE_DATE THEN 'Past Due'
WHEN WO.DATE_COMPLETED IS NULL AND CURRENT_TIMESTAMP <= WO.DUE_DATE THEN 'On Time'
ELSE 'Missed Scenario' END AS ON_TIME
FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS AS WO
LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_STATUSES AS WOS
ON WO.WORK_ORDER_STATUS_ID = WOS.WORK_ORDER_STATUS_ID
LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_TYPES AS WOT
ON WO.WORK_ORDER_TYPE_ID = WOT.WORK_ORDER_TYPE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
ON U.USER_ID = WO.CREATOR_USER_ID
WHERE U.EMPLOYEE_ID IN (
'3460',
'3136',
'2591',
'2564',
'3315',
'982',
'2128',
'2055',
'2675',
'553',
'2152',
'2466',
'477',
'3358',
'3309',
'2436',
'940',
'3122',
'3415',
'561',
'2547',
'2507',
'3120',
'2414',
'2522',
'2032',
'577',
'1058',
'1085',
'2786',
'3445',
'2605',
'606',
'1001',
'2092',
'3402',
'925',
'2506',
'3496',
'2825',
'2877',
'898',
'3026',
'858',
'2545',
'3427',
'3523',
'3574'
)
                             ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}.WORK_ORDER_ID ;;
  }

  dimension: work_order_status {
    type: string
    sql: ${TABLE}.WORK_ORDER_STATUS ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}.URGENCY_LEVEL_ID ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}.CREATOR_USER_ID ;;
  }

  dimension: creator_name {
    type: string
    sql: ${TABLE}.CREATOR_NAME ;;
  }

  dimension: creator_paycor_id {
    type: string
    sql: ${TABLE}.CREATOR_PAYCOR_ID ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}.WORK_ORDER_TYPE ;;
  }

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}.MILEAGE_AT_SERVICE ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}.HOURS_AT_SERVICE ;;
  }

  dimension: due_date {
    type: date_time
    sql: ${TABLE}.DUE_DATE ;;
  }

 dimension: date_created {
  type: date_time
  sql: ${TABLE}.DATE_CREATED ;;
}

  dimension: date_completed {
    type: date_time
    sql: ${TABLE}.DATE_COMPLETED ;;
  }

  dimension: hours_spent_on_work_order {
    type: number
    sql: ${TABLE}.HOURS_SPENT_ON_WORK_ORDER ;;
  }

  dimension: on_time {
    type: string
    sql: ${TABLE}.ON_TIME ;;
  }

  }
