#
# The purpose of this view is to consolidate aggregates for the headcount allocation work order
# and inspection totals for service with additional drill down details.
#
# Britt Shanklin | Built 2022-10-16

view: work_order_completed {
    derived_table: {
      sql:
          SELECT
          DISTINCT CA.PARAMETERS:work_order_id AS WORK_ORDER_ID,
          WOBT.NAME AS TAG,
          WO.DESCRIPTION,
          WO.WORK_ORDER_TYPE_ID,
          WO.DATE_COMPLETED,
          CA.USER_ID,
          CA.DATE_CREATED,
          CA.COMMAND_AUDIT_ID
          FROM ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT AS CA
          LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS_BY_TAG AS WOBT
          ON CA.PARAMETERS:work_order_id = WOBT.WORK_ORDER_ID
          LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
          ON ca.PARAMETERS:work_order_id=wo.WORK_ORDER_ID
          WHERE CA.COMMAND = 'CloseWorkOrder'
          AND (CA.DATE_CREATED > CURRENT_TIMESTAMP()::DATE - interval '3 months'
          OR WO.DATE_COMPLETED > CURRENT_TIMESTAMP()::DATE - interval '3 months')
       ;;
    }

    dimension_group: date_created {
      type: time
      label: "WO close"
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."DATE_CREATED" ;;
    }

  dimension_group: date_completed {
    type: time
    label: "Inspection close"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

    dimension: tag {
      type: string
      sql: ${TABLE}."TAG" ;;
    }

    dimension: work_order_type_id {
      type: number
      sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
    }

    dimension: user_id {
      type: number
      sql: ${TABLE}."USER_ID" ;;
    }

    dimension: work_order_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."WORK_ORDER_ID"  ;;
    }

  dimension: command_audit_id {
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

    dimension:  command_is_last_month {
      type: yesno
      sql: date_part(month,${date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
        and date_part(year,${date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
    }

    dimension:  command_is_current_month {
      type: yesno
      sql: date_part(day,${date_created_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
          and date_part(year,${date_created_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
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

    dimension: work_order_is_null {
      type: yesno
      sql: ${work_order_id} IS NULL ;;
    }

    dimension: is_inspection {
      type: yesno
      sql: ${work_order_type_id} = 2 ;;
    }

    dimension: work_order_id_with_link_to_work_order {
      type: string
      sql: ${work_order_id} ;;
      html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
    }

    measure: total_work_orders_last_month {
      type: count
      filters: [work_order_is_null: "No",
        completed_last_month: "Yes",
        is_inspection: "No"]
      drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
    }

    measure: total_work_orders_mtd {
      type: count
      filters: [ work_order_is_null: "No",
        completed_mtd: "Yes",
        is_inspection: "No"]
      drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
    }

    measure: total_inspections_last_month {
      type: count
      filters: [ completed_last_month: "Yes",
        is_inspection: "Yes"]
      drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
    }

    measure: total_inspections_mtd {
    type: count
    filters: [ completed_mtd: "Yes",
      is_inspection: "Yes"]
    drill_fields: [employee_branch_ukg.full_employee_name, date_completed_date, work_order_id_with_link_to_work_order]
  }

  }
