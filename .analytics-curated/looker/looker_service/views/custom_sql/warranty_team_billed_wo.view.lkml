view: warranty_team_billed_wo {
  derived_table: {
    sql:
    select
        etp.EMPLOYEE_ID,
        etp.IS_WARRANTY_TEAM,
        ca.PARAMETERS:work_order_id as work_order_id,
        ca.DATE_CREATED
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join ES_WAREHOUSE.PUBLIC.USERS u
        on ca.USER_ID = u.USER_ID
    join FLEET_OPTIMIZATION.GOLD.DIM_EMPLOYEE_TITLE_PIT etp
        on try_to_number(u.EMPLOYEE_ID) = etp.EMPLOYEE_ID
    where ca.command = 'UpdateWorkOrder'
    and ca.PARAMETERS:changes:work_order_status_id = 3
    qualify row_number() over (partition by work_order_id order by ca.DATE_CREATED desc) = 1;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }
  dimension: is_warranty_team {
    type: yesno
    sql: ${TABLE}."IS_WARRANTY_TEAM" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
}
