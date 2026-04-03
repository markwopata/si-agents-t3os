view: work_order_inspections_completed {
  derived_table: {
    sql:
SELECT DISTINCT CA.PARAMETERS:work_order_id AS WORK_ORDER_ID,
WOBT.NAME AS TAG,
WO.DESCRIPTION,
WOBT.DATE_COMPLETED
--COUNT(WOBT.DATE_COMPLETED) AS INSPECTIONS_COMPLETED_IN_MONTH
FROM ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT AS CA
INNER JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS_BY_TAG AS WOBT
ON CA.PARAMETERS:work_order_id = WOBT.WORK_ORDER_ID
inner join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
on ca.PARAMETERS:work_order_id=wo.WORK_ORDER_ID
WHERE CA.COMMAND = 'CloseWorkOrder'
AND (WOBT.NAME = 'Inspection completed'
OR wo.WORK_ORDER_TYPE_ID = 2)
AND CA.PARAMETERS:work_order_id IS NOT NULL
AND WOBT.DATE_COMPLETED > CURRENT_TIMESTAMP()::DATE - interval '3 months'
;;
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: tag {
    type: string
    sql: ${TABLE}."TAG" ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: inspection_is_completed {
    type: yesno
    sql: ${date_completed_date} IS NOT NULL ;;
  }

  dimension:  completed_last_month {
    type: yesno
    sql: date_part(month,${date_completed_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
      and date_part(year,${date_completed_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension:  completed_mtd {
    type: yesno
    sql: date_part(day,${date_completed_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${date_completed_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${date_completed_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  measure: total_wo_inspections_last_month {
    type: count
    filters: [completed_last_month: "Yes",
              inspection_is_completed: "Yes"]
    drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
  }

  measure: total_wo_inspections_mtd {
    type: count
    filters: [completed_mtd: "Yes",
      inspection_is_completed: "Yes"]
    drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
  }

 }
